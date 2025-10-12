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
  # Red text
  echo -e "\033[1;31m"$*"\033[0m"
}

warn() {
  # Yellow text
  echo -e "\033[1;33m"$*"\033[0m"
}

success() {
  # Green text
  echo -e "\033[1;32m"$*"\033[0m"
}
