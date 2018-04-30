import yaml
from mako.template import Template
import collections
from sys import argv
from os import path, environ


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


def flatten(d, parent_key='', sep='_'):
    items = []
    for k, v in d.items():
        new_key = parent_key + sep + k if parent_key else k
        if isinstance(v, dict) and v:
            items.extend(flatten(v, new_key, sep=sep).items())
        elif isinstance(v, list) and not isinstance(v, basestring):
            for ind in range(len(v)):
                new_key = "{}{}#{}".format(new_key, sep, ind)
                if isinstance(v[ind], dict):
                    items.extend(flatten(v[ind], new_key, sep=sep).items())
                else:
                    items.append((new_key, v[ind]))
        else:
            items.append((new_key, v))
    return dict(items)

kubifyStatePath = argv[1]
landscapeConfig = argv[2]
kubifyHome = argv[3]

y = yaml.load(open(landscapeConfig))

variant = y['cloud']['variant']

vname = open(path.join(kubifyStatePath, "variant_name.tmp"), 'w')
vname.write(variant)
vname.close()

#print("Filling template for variant {}...".format(variant))
removeVariantNodes(y)
tmp = y
y = flatten(y, sep='.')
y['yaml_map'] = tmp # add the non-flattened map to y for better searching
terraformTemplate = Template(filename=path.join(kubifyHome, 'terraform.tfvars.{}.template'.format(variant)))
filledTemplate = terraformTemplate.render(**y)
print(filledTemplate)

#print("Writing terraform.tfvars ...")
tfvars = open(path.join(environ["LANDSCAPE_HOME"], "terraform.tfvars"), 'w')
tfvars.write(filledTemplate)
tfvars.close()
#print("Generation of terraform.tfvars finished!")

