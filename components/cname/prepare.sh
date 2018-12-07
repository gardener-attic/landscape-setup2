#!/bin/bash -eu
#
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

if [[ $1 = "deploy" ]] ; then
  action="UPSERT"
elif [[ $1 = "undeploy" ]] ; then
  action="DELETE"
else
  fail "Unknown argument: $1"
fi

AWS_CLI_PROFILE=${AWS_CLI_PROFILE:-"aws-gardener"}

dns="$(read_landscape_config '.clusters.dns')"

hosted_zone="$(jq -r '.hosted_zone_id' <<< $dns)"
domain="$(jq -r '.domain_name' <<< $dns)"
ingress_domain="\\\\052.ingress.${domain}."

# configure aws cli
aws configure set aws_access_key_id "$(jq -r '.access_key' <<< $dns)" --profile "$AWS_CLI_PROFILE"
aws configure set aws_secret_access_key "$(jq -r '.secret_key' <<< $dns)" --profile "$AWS_CLI_PROFILE"
aws configure set region "$(read_landscape_config '.authentication.variant_aws.aws_region')" --profile "$AWS_CLI_PROFILE"

max_retry_time=300
retry_stop=$(($(date +%s) + max_retry_time))
success=false
while [[ $(date +%s) -lt $retry_stop ]]; do
  # extract ingress ip from dashboard ingress
  ip="$(kubectl -n garden get ingress gardener-dashboard-ingress -o jsonpath='{.status.loadBalancer.ingress[0].ip}')"
  # if no ip found, try for hostname
  ip=${ip:-"$(kubectl -n garden get ingress gardener-dashboard-ingress -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')"}
  if [[ -n ${ip:-""} ]] ; then
    success=true
    break;
  fi
  debug "Waiting for dashboard ingress to get an IP ..."
  sleep 1
done
if ! $success; then
  fail "Dashboard ingress did not get an IP within $max_retry_time seconds!"
fi

# check if CNAME entry already exists
entry=$(aws route53 list-resource-record-sets --hosted-zone-id "$hosted_zone" --output json --query "ResourceRecordSets[?Type==\`CNAME\` && Name==\`${ingress_domain}\`] | [0]" --profile "$AWS_CLI_PROFILE")

change_batch=$(cat << EOF
{
  "Changes": [
    {
      "Action": "${action}",
      "ResourceRecordSet": {
        "Name": "${ingress_domain}",
        "Type": "CNAME",
        "TTL": 300,
        "ResourceRecords": [
          {
            "Value": "${ip}"
          }
        ]
      }
    }
  ]
}
EOF
)

