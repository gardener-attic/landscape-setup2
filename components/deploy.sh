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

source ${LANDSCAPE_SCRIPTS_HOME}/common
source ${LANDSCAPE_SCRIPTS_HOME}/lib/stack

# workaround for Ubuntu 14.04 jumpboxes where a modern realpath is missing that supports the
# --relative-to option; this workaround assumes the base_path to be an absolute canonical path
function realpath_relative_to() {
  local base_path="$1"
  local path="$2"
  [[ "$base_path" != */ ]] && base_path="$base_path/"
  [[ "$path" != */ ]] && path="$path/"
  local rel_path="${path#$base_path}"
  if [[ "$rel_path" == "$path" ]]; then
    echo "..." # we don't need to know exactly how far we are outside
  elif [[ "$rel_path" == "" ]]; then
    echo "."
  else
    rel_path="${rel_path%/}"
    echo "${rel_path#./}"
  fi
}

function calc_paths() {

  local relsuf=/$1
  COMPONENT_EXPORT_HOME="$LANDSCAPE_EXPORT_HOME$relsuf"
  COMPONENT_STATE_HOME="$LANDSCAPE_STATE_HOME$relsuf"
  COMPONENT_TEMPLATE_HOME="$LANDSCAPE_COMPONENTS_HOME$relsuf"
}

# call deploy script
function call_deploy() {
  # check that there is a deploy script
  if [[ ! -f "$COMPONENT_TEMPLATE_HOME/deploy" ]]; then
    fail "No deploy script available in $COMPONENT_TEMPLATE_HOME!"
  fi

  # create export and state folders which may be missing initially
  mkdir -p "$COMPONENT_EXPORT_HOME"
  mkdir -p "$COMPONENT_STATE_HOME"

  # call the deploy script (in its own folder)
  echo -e "┌───────────"
  echo -e "│ Component: $(color inverse_cyan $(realpath_relative_to "$LANDSCAPE_COMPONENTS_HOME" "$COMPONENT_TEMPLATE_HOME"))"
  echo -e "│      Exec: $(color light_gray $(realpath_relative_to "$LANDSCAPE_HOME" "$COMPONENT_TEMPLATE_HOME")/deploy) $(color blue "$@")"
# echo -e "│    Export: $(color light_gray $(realpath_relative_to "$LANDSCAPE_HOME" "$COMPONENT_EXPORT_HOME"))"
# echo -e "│     State: $(color light_gray $(realpath_relative_to "$LANDSCAPE_HOME" "$COMPONENT_STATE_HOME"))"
  echo -e "└───────────"
  pushd "$COMPONENT_TEMPLATE_HOME" 1> /dev/null
  export COMPONENT_EXPORT_HOME
  export COMPONENT_STATE_HOME
  export COMPONENT_TEMPLATE_HOME
  source ./deploy "$@"
  popd 1> /dev/null
}

stack_new component_export_home_stack
stack_new component_state_home_stack
stack_new component_template_home_stack

calc_paths $1
call_deploy $@
