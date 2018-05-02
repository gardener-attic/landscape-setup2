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
import argparse
import os
import yaml
import json
import sys

# import our utility library
sys.path.insert(0, os.path.join(os.environ["LANDSCAPE_SCRIPTS_HOME"], "lib"))
import utils

config=yaml.load(open(os.environ["LANDSCAPE_CONFIG"]))

accessDomain = config["clusters"]["dns"]["domain_name"]


config={
    "hosts": [
        accessDomain,
        "*." + accessDomain,
        "*.ingress." + accessDomain
    ],
    "CN": accessDomain,
    "key": {
        "algo": "rsa",
        "size": 2048
    }
}

json.dump(config, sys.stdout, indent=2)
