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
import sys

# import our utility library
sys.path.insert(0, os.path.join(os.environ["LANDSCAPE_SCRIPTS_HOME"], "lib"))
import utils

parser=argparse.ArgumentParser(description="Compute the Gardener Helm chart values.")
parser.add_argument("--etcd-server", dest="etcd_server", required=True, help="ip:port of etcd cluster address")
parser.add_argument("--gardener-repo-path", dest="gardener_repo_path", required=True, help="path to the Gardener repository")
args=parser.parse_args()

config=yaml.load(open(os.environ["LANDSCAPE_CONFIG"]))

gardener_config=utils.find_by_key_value(config["charts"], "name", "gardener")

image_tag=utils.find_by_key_value(config["charts"], "name", "gardener")["tag"]

values={
  "apiserver": {
    "caBundle": utils.read_file(os.path.join(os.environ["LANDSCAPE_STATE_HOME"], "cert", "ca.crt")),
    "image": {
      "tag": image_tag
    },
    "tls": {
      "crt": utils.read_file(os.path.join(os.environ["COMPONENT_STATE_HOME"], "tls", "gardener-apiserver-tls.pem")),
      "key": utils.read_file(os.path.join(os.environ["COMPONENT_STATE_HOME"], "tls", "gardener-apiserver-tls-key.pem")),
    },
    "etcd": {
      "servers": args.etcd_server,
      "caBundle": utils.read_file(os.path.join(os.environ["LANDSCAPE_ACTIVE_CLUSTER_REPO_PATH"], "gen", "assets", "tls", "etcd-client-ca.crt")),
      "tls": {
        "crt": utils.read_file(os.path.join(os.environ["LANDSCAPE_ACTIVE_CLUSTER_REPO_PATH"], "gen", "assets", "tls", "etcd-client.crt")),
        "key": utils.read_file(os.path.join(os.environ["LANDSCAPE_ACTIVE_CLUSTER_REPO_PATH"], "gen", "assets", "tls", "etcd-client.key"))
      },
    }
  },
  "controller": {
    "image": {
      "tag": image_tag
    },
    "internalDomain": {
      "provider": gardener_config["values"]["controller"]["internalDomain"]["provider"],
      "domain": gardener_config["values"]["controller"]["internalDomain"]["domain"],
      "hostedZoneID": gardener_config["values"]["controller"]["internalDomain"]["hostedZoneID"],
      "credentials": {
        "accessKeyID": gardener_config["values"]["controller"]["internalDomain"]["access_key"],
        "secretAccessKey": gardener_config["values"]["controller"]["internalDomain"]["secret_key"]
      }
    },
    "defaultDomains": [],
    "gitHub": [],
    "openVPNDiffieHellmanKey": gardener_config["openVPNDiffieHellmanKey"],
#    "alertingSMTP": gardener_config["values"]["controller"]["alertingSMTP"],
    "config": {
      "controllers": {
        "seed": {
          "reserveExcessCapacity": False,
        }
      },
      "server": {
        "https": {
          "tls": {
            "caBundle": utils.read_file(os.path.join(os.environ["LANDSCAPE_STATE_HOME"], "cert", "ca.crt")),
            "crt": utils.read_file(os.path.join(os.environ["COMPONENT_STATE_HOME"], "tls", "gardener-controller-manager-tls.pem")),
            "key": utils.read_file(os.path.join(os.environ["COMPONENT_STATE_HOME"], "tls", "gardener-controller-manager-tls-key.pem"))
          }
        }
      }
    }
  }
}

for domain in gardener_config["values"]["controller"]["defaultDomains"]:
  values["controller"]["defaultDomains"].append({
    "provider": domain["provider"],
    "domain": domain["domain"],
    "hostedZoneID": domain["hostedZoneID"],
    "credentials": {
      "accessKeyID": domain["access_key"],
      "secretAccessKey": domain["secret_key"]
    }
  })

yaml.safe_dump(values, sys.stdout, indent=2, width=100000, default_style='\"')
