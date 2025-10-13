#!/bin/bash

export_env_dir() {
  local env_dir=$1
  if [ -d "$env_dir" ]; then
    local e
    for e in $(ls $env_dir); do
      echo "$e=$(cat $env_dir/$e)"
      export "$e=$(cat $env_dir/$e | sed -e 's/^"//' -e 's/"$//')"
    done
  fi
}

indent() {
  sed -u 's/^/       /'
}

header() {
  echo ""
  echo "-----> $*"
}

error() {
  echo " !     $*" >&2
  exit 1
}

warn() {
  echo " !     $*" >&2
}

success() {
  echo "       $*" >&2
}