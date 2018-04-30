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
