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

# evaluate args
i=0
seeds=()
if [ $# -gt 0 ]; then
    for arg in "$@"; do
        if [ $arg == "aws" -o $arg == "openstack" -o $arg == "az" -o $arg == "gcp" ]; then
            seeds[$((i++))]=$arg
        else 
            echo "Unknown seed-config argument: $arg"
            exit 1
        fi
    done
fi

# read seeds from landscape config if not specified in args
if [ $i -eq 0 ]; then 
    for seed in $(read_landscape_config '.seed_config.seeds[]'); do
        seeds[$((i++))]=$seed
    done
fi

# do not proceed if no seeds have been specified
if [ ${#seeds[@]} -eq 0 ]; then 
    fail "No seeds defined (neither in landscape config, nor in arguments)!"
fi

# iterate over all files in the state folder that belong to specified seeds
# deploy or delete resources
export seeds
