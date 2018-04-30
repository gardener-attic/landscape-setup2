#!/bin/bash

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
call_deploy $1
