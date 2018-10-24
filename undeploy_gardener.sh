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

pushd "$LANDSCAPE_COMPONENTS_HOME" 1> /dev/null

if [ $# -gt 0 ]; then 
    arg="$1"
else 
    arg=dashboard
fi

# if gardener is still deployed, remove shoots
# this is done before so that e.g. the dashboard is not deleted
# in case something with the shoot deletion doesn't work.
case $arg in 
    (certmanager)
        ;&
    (dashboard)
        ;&
    (identity)
        ;&
    (seed-config)
        ;&
    (gardener)
        echo "Deleting remaining shoots, if any ..."
        $SETUP_REPO_PATH/delete_all.sh shoots
        if [ $(kubectl get shoots --all-namespaces 2> /dev/null | wc -l) -gt 0 ] ; then
            fail "It seems there are still shoots left! Undeploy has been stopped."
        fi 
        echo "Deleting remaining projects, if any ..."
        $SETUP_REPO_PATH/delete_all.sh projects
        ;;
esac

# remove components
echo "Removing components..."
case $arg in
    (certmanager)
        # certmanager 
        undeploy dashboard
        ;&
    (dashboard)
        # dashboard 
        undeploy dashboard
        ;&
    (identity)
        # identity
        undeploy identity
        ;&
    (seed-config)
        # register garden cluster as seed cluster
        # workaround: will delete all possible seeds, even if not created
        undeploy seed-config aws az gcp openstack
        ;&
    (gardener) 
        # gardener
        undeploy gardener
        ;&
    (helm-tiller) 
        # helm-tiller
        undeploy helm-tiller
        ;&
    (cert) 
        # certificates
        undeploy cert
        ;;
    (*)
        # something else
        fail "Unknown argument: $arg"
        ;;
esac

popd 1> /dev/null

echo "Uninstall complete!"