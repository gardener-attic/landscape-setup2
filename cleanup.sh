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

# This script will delete resources that are left over after teardown of the cluster.
# DO NOT USE THIS IF YOUR CLUSTER IS STILL ACTIVE!

if [ $# -gt 0 ] && [ $1 == "-y" ]; then
    confirmed=yes
else
    echo "This will delete the terraform state. Be sure the project is completely deleted from the IaaS layer!"
    echo -n "Are you sure? (yes) "
    read confirmed
fi
if [ "$confirmed" == yes ]; then
    pushd "$LANDSCAPE_HOME" 1> /dev/null
    rm -rf variant terraform.tfvars terraform .terraform terraform.tfstate* state state.auto.tfvars structure-version landscape.yaml export .helm gen rollinfo 
    popd 1> /dev/null
else
    echo "Cleanup aborted."
fi
