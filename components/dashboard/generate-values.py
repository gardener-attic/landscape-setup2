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

parser=argparse.ArgumentParser(description="Compute the Dashboard Helm chart values.")
parser.add_argument("--dashboard-repo-path", dest="dashboard_repo_path", required=True, help="path to the Dashboard repository")
parser.add_argument("--tls-crt-path", dest="tls_crt_path", required=True, help="path to the tls.crt")
parser.add_argument("--tls-key-path", dest="tls_key_path", required=True, help="path to the tls.key")
args=parser.parse_args()

config=yaml.load(open(os.environ["LANDSCAPE_CONFIG"]))

domain=config["clusters"]["dns"]["domain_name"]
image_tag=utils.find_by_key_value(config["charts"], "name", "dashboard")["tag"]

dashboard_config=utils.find_by_key_value(config["charts"], "name", "dashboard")

values={
  "image": {
    "tag": image_tag,
  },
  "hosts": [
    "dashboard.ingress." + domain,
  ],
  "tls": {
    "crt": utils.read_file(args.tls_crt_path),
    "key": utils.read_file(args.tls_key_path)
  },
  "oidc": {
    "issuerUrl": "https://identity.ingress." + domain,
    "clientId": "dashboard",
  },
  "frontend": {
    "landingPageUrl": "https://github.com/gardener/",
    "helpMenuItems": [
      {
        "title": "Getting Started",
        "icon": "description",
        "url": "https://github.com/gardener/"
      },
      {
        "title": "How To",
        "icon": "question_answer",
        "url": "https://github.com/gardener/"
      },
      {
        "title": "Feedback",
        "icon": "thumbs_up_down",
        "url": "https://github.com/gardener/"
      },
      {
        "title": "Compose Message",
        "icon": "email",
        "url": "mailto:gardener@googlegroups.com",
        "target": "_self"
      }
    ]
  }
}

yaml.safe_dump(values, sys.stdout, indent=2, width=100000, default_style='\"')
