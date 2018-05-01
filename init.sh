#!/bin/bash
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

# preserve original path
export SETUP_NON_WRAPPED_PATH="$PATH"

# landscape home is one level higher
landscape_homet="$(readlink -f "${BASH_SOURCE[0]}")"
landscape_homev="$(dirname ${landscape_homet})"
landscape_home="$(dirname ${landscape_homev})"
export LANDSCAPE_HOME=$landscape_home

# repositories
export GARDENER_REPO_PATH=${LANDSCAPE_HOME}/gardener
export DASHBOARD_REPO_PATH=${LANDSCAPE_HOME}/dashboard
export KUBIFY_REPO_PATH=${LANDSCAPE_HOME}/k8s
export SETUP_REPO_PATH=${LANDSCAPE_HOME}/setup

export KUBIFY_STATE_PATH=${LANDSCAPE_HOME}

export LANDSCAPE_SCRIPTS_HOME="${SETUP_REPO_PATH}/bin"

export LANDSCAPE_CONFIG="$LANDSCAPE_HOME/landscape.yaml"
export LANDSCAPE_STATE_HOME="$LANDSCAPE_HOME/state"
export LANDSCAPE_COMPONENTS_HOME="$LANDSCAPE_HOME/setup/components"
export LANDSCAPE_EXPORT_HOME="$LANDSCAPE_HOME/export"

export PATH=${SETUP_REPO_PATH}/bin:$PATH

export LANDSCAPE_NAME="$(grep -m 1 -F "domain_name:" "$LANDSCAPE_HOME/landscape.yaml" | awk '{ print $2 }')"

export LANDSCAPE_ACTIVE_CLUSTER_REPO_PATH=$LANDSCAPE_HOME
export LANDSCAPE_ACTIVE_CLUSTER_NAME=todo

if [ ! -d ${LANDSCAPE_STATE_HOME} ] ; then
    mkdir -p ${LANDSCAPE_STATE_HOME}
fi

source ${SETUP_REPO_PATH}/bin/common
