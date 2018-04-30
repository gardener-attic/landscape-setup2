import argparse
import os
import yaml
import sys
from subprocess import check_output

# import our utility library
sys.path.insert(0, os.path.join(os.environ["LANDSCAPE_SCRIPTS_HOME"], "lib"))
import utils

parser=argparse.ArgumentParser(description="Compute the Identity Helm chart values.")
parser.add_argument("--tls-crt-path", dest="tls_crt_path", required=True, help="path to the tls.crt")
parser.add_argument("--tls-key-path", dest="tls_key_path", required=True, help="path to the tls.key")
args=parser.parse_args()

config=yaml.load(open(os.environ["LANDSCAPE_CONFIG"]))
identity_config=utils.find_by_key_value(config["charts"], "name", "identity")

domain=config["clusters"]["dns"]["domain_name"]
image_tag=utils.find_by_key_value(config["charts"], "name", "identity")["tag"] 

passwords=identity_config["staticPasswords"]

for entry in passwords:
    if "password" in entry:
        password=entry["password"]
        hashval=check_output("htpasswd -bnBC 10 \"\" " + password + " | tr -d ':\n' | sed 's/$2y/$2a/'", shell=True)
        entry["hash"] = hashval
        del entry["password"] 

values={
  "image": {
    "tag": image_tag,
  },
  "hosts": [
    "identity.ingress." + domain,
  ],
  "tls": {
    "crt": utils.read_file(args.tls_crt_path),
    "key": utils.read_file(args.tls_key_path)
  },
  "issuerUrl": "https://identity.ingress." + domain,
  "dashboardOrigins": [
    "https://dashboard.ingress." + domain,
    "http://localhost:8080"
  ],
  "dashboardClientSecret": utils.read_file(os.path.join(os.environ["COMPONENT_STATE_HOME"], "dashboardClientSecret")),
  "kubectlClientSecret": utils.read_file(os.path.join(os.environ["COMPONENT_STATE_HOME"], "kubectlClientSecret")),
  "staticPasswords": passwords,
  "connectors" : []
}

yaml.safe_dump(values, sys.stdout, indent=2, width=100000, default_style='\"')
