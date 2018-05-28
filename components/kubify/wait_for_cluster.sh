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

echo "Waiting for the cluster ..."
if [ $# -lt 1 ] || [ $1 != "-nw" -a $1 != "--no-wait" ]; then # allow skipping the time for testing purposes
  echo "Give the cluster some time to come up ... (waiting for 5 minutes)"
  sleep 300
fi

max_retry_time=900
retry_stop=$(($(date +%s) + max_retry_time))
success=false
while [[ $(date +%s) -lt $retry_stop ]]; do
  if kubectl get pods &> /dev/null; then
    success=true
    break;
  fi
  echo "Cluster not yet reachable. Waiting ..."
  sleep 30
done
if ! $success; then
  fail "Cluster did not become reachable within $max_retry_time seconds!"
fi

echo "Cluster reachable. Waiting for all pods to be running ..."

master_count="$(yaml2json < $LANDSCAPE_CONFIG | jq -r .clusters.master.count)"
worker_count="$(yaml2json < $LANDSCAPE_CONFIG | jq -r .clusters.worker.count)"
max_retry_time=600
retry_stop=$(($(date +%s) + max_retry_time))
success=false
phase=3
while [[ $(date +%s) -lt $retry_stop ]]; do
  case $phase in
  (3) # check: #apiserver == #master nodes
    api_count=$(kubectl -n kube-system get pods | grep -i kube-apiserver | wc -l) &> /dev/null
    if [ $api_count -eq $master_count ]; then
      echo "Amount of api server pods equals specified amount of master nodes: $api_count"
      ((phase=$phase-1)) || true
      continue;
    fi
    echo "Amount of api server pods ($api_count) doesn't equal specified amount of master nodes ($master_count) yet. Waiting ..."
    ;;
  (2) # check: #etcd == #master nodes
    etcd_count=$(kubectl -n kube-system get pods | grep -i -E "kube-etcd-.... " | wc -l) &> /dev/null
    if [ $etcd_count -eq $master_count ]; then
      echo "Amount of etcd pods equals specified amount of master nodes: $etcd_count"
      ((phase=$phase-1)) || true
      continue;
    fi
    echo "Amount of etcd pods ($etcd_count) doesn't equal specified amount of master nodes ($master_count) yet. Waiting ..."
    ;;
  (1) # check: #ingress == #worker nodes
    ingress_count=$(kubectl -n nginx-ingress get pods | grep -i nginx-ingress-controller | wc -l) &> /dev/null
    if [ $ingress_count -eq $worker_count ]; then
      echo "Amount of ingress pods equals specified amount of worker nodes: $ingress_count"
      ((phase=$phase-1)) || true
      continue;
    fi
    echo "Amount of ingress pods ($ingress_count) doesn't equal specified amount of worker nodes ($worker_count) yet. Waiting ..."
    ;;
  (0) # check: #pods == #running pods
    pod_count=$(kubectl get pods --all-namespaces | wc -l) &> /dev/null
    ((pod_count=$pod_count-1))  || true # substract headline
    running_pod_count=$(kubectl get pods --field-selector=status.phase=Running --all-namespaces | wc -l) &> /dev/null
    ((running_pod_count=$running_pod_count-1))  || true # substract headline
    if [ $pod_count -gt 0 ] && [ $pod_count -eq $running_pod_count ]; then
      echo "Cluster is up and all pods are running!"      
      success=true
      break;
    fi
    echo "$running_pod_count of $pod_count pods are running. Waiting ..."
    ;;
  (*) # just decrease phase
    echo "No valid phase: $phase"
    if [ $phase -gt 0 ]; then 
      ((phase=$phase-1)) || true
      continue;
    else
      break;
    fi
    ;;
  esac
  sleep 10
done
if ! $success; then
  case $phase in
    (3) fail "Amount of api server pods ($api_count) didn't equal specified amount of master nodes ($master_count) within $max_retry_time seconds!" ;;
    (2) fail "Amount of etcd pods ($etcd_count) didn't equal specified amount of master nodes ($master_count) within $max_retry_time seconds!" ;;
    (1) fail "Amount of ingress pods ($ingress_count) didn't equal specified amount of master nodes ($worker_count) within $max_retry_time seconds!" ;;
    (0) fail "Not all pods ($running_pod_count/$pod_count) were running within $max_retry_time seconds!" ;;
  esac
fi

