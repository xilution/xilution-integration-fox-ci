#!/bin/bash -e

[ -z "$CODEBUILD_SRC_DIR_SourceCode" ] && echo "Didn't find CODEBUILD_SRC_DIR_SourceCode env var." && exit 1
[ -z "$XILUTION_CONFIG" ] && echo "Didn't find XILUTION_CONFIG env var." && exit 1

. ./scripts/common-functions.sh

sourceDir=${CODEBUILD_SRC_DIR_SourceCode}
currentDir=$(pwd)

cd "${sourceDir}" || false

commands=$(echo "${XILUTION_CONFIG}" | base64 --decode | jq -r ".verify.commands[] | @base64")
execute_commands "${commands}"

cd "${currentDir}" || false

echo "All Done!"
