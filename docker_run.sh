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

# read latest version from file
CURRENT_IMAGE_VERSION=$(<VERSION)
IMAGE_NAME="eu.gcr.io/gardener-project/gardener/gardener-setup"

# check if image exists - if not, pull from repo
if ! docker images | grep $IMAGE_NAME | grep $CURRENT_IMAGE_VERSION &> /dev/null ; then
    # pull image
    echo "Image $IMAGE_NAME:$CURRENT_IMAGE_VERSION not found locally - pulling it from repository ..."
    docker pull "$IMAGE_NAME:$CURRENT_IMAGE_VERSION"
fi 

# Run the docker container with interactive shell, cd to the mounted folder, and source the init.sh file
# the "&& bash" keeps the interactive mode of the docker container alive
docker run -it -v $(pwd)/..:/landscape -w /landscape/setup "$IMAGE_NAME:$CURRENT_IMAGE_VERSION" bash -c "source /landscape/setup/init.sh && bash"