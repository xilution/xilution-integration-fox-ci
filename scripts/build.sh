#!/bin/bash

. ./scripts/common_functions.sh

stageName=${1}
sourceDir=${2}

currentDir=$(pwd)
cd "${sourceDir}" || false

commands=$(jq -r ".builds?.${stageName}?.commands[]? | @base64" <./xilution.json)
execute_commands "${commands}"

distDir=$(jq -r ".builds?.distDir?" <./xilution.json)

if [[ "${distDir}" == "null" ]]; then
  echo "Unable to find distribution directory."
  exit 1
fi

cd "${distDir}" || false

zip -r ../dist.zip .
mv ../dist.zip "${currentDir}"

cd "${currentDir}" || false
