#!/bin/bash -e

execute_commands() {

  [ -z "$1" ] && echo "The first argument should be commands." && exit 1

  commands=${1}

  for command in ${commands}; do
    echo "${command}" | base64 --decode | bash
  done
}
