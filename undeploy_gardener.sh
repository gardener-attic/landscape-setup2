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

echo "Removing components..."

pushd "$LANDSCAPE_COMPONENTS_HOME" 1> /dev/null

if [ $# -gt 0 ]; then 
    arg="$1"
else 
    arg=dashboard
fi
case $arg in
    (dashboard)
        # dashboard 
        ./deploy.sh dashboard --uninstall
        ;&
    (identity)
        # identity
        ./deploy.sh identity --uninstall
        ;&
    (seed-config)
        # register garden cluster as seed cluster
        # workaround: will delete all possible seeds, even if not created
        ./deploy.sh seed-config --uninstall aws az gcp openstack
        ;&
    (gardener) 
        # gardener
        ./deploy.sh gardener --uninstall
        ;&
    (helm-tiller) 
        # helm-tiller
        ./deploy.sh helm-tiller --uninstall
        ;&
    (cert) 
        # certificates
        ./deploy.sh cert --uninstall
        ;;
    (*)
        # something else
        fail "Unknown argument: $arg"
        ;;
esac

popd 1> /dev/null

echo "Uninstall complete!"