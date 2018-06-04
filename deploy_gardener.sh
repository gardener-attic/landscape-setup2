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

# should already have happened
# source setup/init.sh

pushd "$LANDSCAPE_COMPONENTS_HOME" 1> /dev/null

# kubify - not yet automated
#./deploy.sh kubify

# certificates
./deploy.sh cert

# helm-tiller
./deploy.sh helm-tiller

# gardener
./deploy.sh gardener

# register garden cluster as seed cluster
./deploy.sh seed-config

# identity
./deploy.sh identity

# dashboard 
./deploy.sh dashboard

# certmanager - there's an extra script for that
#./deploy.sh certmanager

popd 1> /dev/null

echo "Gardener successfully deployed!"