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
