#!/bin/bash

. ./scripts/common_functions.sh

sourceDir=${1}

cd "${sourceDir}" || false

commands=$(jq -r ".verify?.commands[]? | @base64" <./xilution.json)
execute_commands "${commands}"
