#!/bin/bash -e

[ -z "$XILUTION_CONFIG" ] && echo "Didn't find XILUTION_CONFIG env var." && exit 1

. ./scripts/common-functions.sh

commands=$(echo "${XILUTION_CONFIG}" | base64 --decode | jq -r ".verify.commands[] | @base64")
execute_commands "${commands}"

echo "All Done!"
