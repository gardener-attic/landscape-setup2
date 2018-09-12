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

shoots=$(kubectl get shoots --all-namespaces -o json)
len=$(echo "$shoots" | jq ".items | length")

if [ $len -eq 0 ] ; then
    echo "No shoots found!"
fi

for i in $(seq 0 $((len - 1))); do # go from 0 to len-1
    shoot_name=$(echo "$shoots" | jq -r ".items[$i].metadata.name")
    shoot_namespace=$(echo "$shoots" | jq -r ".items[$i].metadata.namespace")

    echo "Deleting shoot $shoot_name in namespace $shoot_namespace ..."
    $GARDENER_REPO_PATH/hack/delete-shoot $shoot_name $shoot_namespace 1> /dev/null & # allow for parallel shoot deletion
done

wait # wait until all shoots are deleted