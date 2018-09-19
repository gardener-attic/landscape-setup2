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

getIP()
{
  local o
  o=$(terraform output $1 2>/dev/null)
  {
    no=$2
    while read a; do
      if [ -n "$o" ]; then
        if [ $no -eq 0 ]; then
          echo ${a%%,}
          return 0
        fi
        no=$((no-1))
      fi
    done
    return 1
  } <<<"$o"
}

doSSH() {
    # do ssh, ignore unknown hosts, don't save hosts, suppress warnings about saving hosts
    ssh -i $pem -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o "ProxyCommand=ssh -i $pem -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -W %h:%p ubuntu@$bastion" core@$ip "$@" 2> >(grep -v "Warning: Permanently added .* to the list of known hosts\.")
}

pushd "$KUBIFY_STATE_PATH" 1> /dev/null
ip=$(getIP master_ips 0)
bastion=$(getIP bastion 0)
pem=$KUBIFY_STATE_PATH/gen/nodes_privatekey.pem
popd 1> /dev/null

if [ $# -gt 0 ] && [ $1 == "start" ] ; then
    debug "Starting bootstrap apiserver ..."
    doSSH "sudo cp -r -f /opt/bootkube/assets/tls/ /etc/kubernetes/bootstrap-secrets"
    doSSH "sudo cp -f /opt/bootkube/assets/bootstrap-manifests/bootstrap-apiserver.yaml /etc/kubernetes/manifests/"
    debug "Bootstrap apiserver started."
elif [ $# -gt 0 ] && [ $1 == "stop" ] ; then
    debug "Stopping bootstrap apiserver ..."
    doSSH "sudo rm -f /etc/kubernetes/manifests/bootstrap-apiserver.yaml"
    doSSH "sudo rm -rf /etc/kubernetes/bootstrap-secrets"
    debug "Bootstrap apiserver stopped."
else 
    fail "Invalid arguments! The bootstrap_apiserver script expects 'start' or 'stop' as parameter!"
fi