# Copyright (c) 2018 SAP SE or an SAP affiliate company. All rights reserved. This file is licensed under the Apache Software License, v. 2 except as noted otherwise in the LICENSE file
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import yaml
from mako.template import Template
from mako.lookup import TemplateLookup
import collections
from sys import argv
from os import path


'''
The landscape.yaml allows for "variant nodes" in the style of:
    authentication:
        variant_all:
            ...
        variant_aws:
            aws_access_key: ...
            ...
        variant_openstack:
            os_user_name: ...
            ...
        ...
This method removes all nodes of this type and adds the corresponding data of the 'variant_all' node and the node of the current variant directly to the level above.
'''
def removeVariantNodes(data):
    isVariantLevel = False
    variantFilter = 'variant_{}'.format(variant)

    for k in data.keys():
        if type(data[k]) is dict:
            removeVariantNodes(data[k])
        if k == 'variant_all' or k == variantFilter:
            isVariantLevel = True
    if isVariantLevel:
        tmp = (data.get('variant_all'), data.get(variantFilter))
        data.clear()
        if tmp[0]:
            data.update(tmp[0])
        if tmp[1]:
            data.update(tmp[1])


kubifyStatePath = argv[1]
landscapeConfig = argv[2]
kubifyHome = argv[3]
landscapeHome = argv[4]

y = yaml.load(open(landscapeConfig))

variant = y['cloud']['variant']

vname = open(path.join(kubifyStatePath, "variant_name.tmp"), 'w')
vname.write(variant)
vname.close()

print("Filling template for variant {}...".format(variant))
removeVariantNodes(y)
ym = dict()
ym['yaml_map'] = y
templateLookup = TemplateLookup(directories=[kubifyHome])
terraformTemplate = templateLookup.get_template(path.join(kubifyHome, '/terraform.tfvars.{}.template'.format(variant)))
filledTemplate = terraformTemplate.render(**ym)
print(filledTemplate)

#print("Writing terraform.tfvars ...")
tfvars = open(path.join(landscapeHome, "terraform.tfvars"), 'w')
tfvars.write(filledTemplate)
tfvars.close()
#print("Generation of terraform.tfvars finished!")

