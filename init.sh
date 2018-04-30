#!/bin/bash

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
