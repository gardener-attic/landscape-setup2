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


# This is the automated part of the gardener installation. 
# It deploys certificates, helm-tiller, gardener, sets the garden clusters as seed cluster, and installs identity and the gardener dashboard
# Prerequesites: kubify cluster

echo "Setting up the cluster ..."

pushd "$LANDSCAPE_COMPONENTS_HOME" 1> /dev/null

if [ $# -gt 0 ]; then 
    arg="$1"
else 
    arg=cert
fi
case $arg in
    (cert) 
        # certificates
        ./deploy.sh cert
        ;&
    (helm-tiller) 
        # helm-tiller
        ./deploy.sh helm-tiller
        ;&
    (gardener) 
        # gardener
        ./deploy.sh gardener
        ;&
    (seed-config)
        # register garden cluster as seed cluster
        ./deploy.sh seed-config
        ;&
    (identity)
        # identity
        ./deploy.sh identity
        ;&
    (dashboard)
        # dashboard 
        ./deploy.sh dashboard
        ;;
    (*)
        # something else
        fail "Unknown argument: $arg"
        ;;
esac

popd 1> /dev/null

echo "Gardener successfully deployed!"
echo ""
$SETUP_REPO_PATH/print_dashboard_urls.sh