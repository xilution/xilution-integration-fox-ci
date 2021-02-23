#!/bin/bash -e

. ./scripts/common_functions.sh

sourceDir=${CODEBUILD_SRC_DIR_SourceCode}

cd "${sourceDir}" || false

commands=$(jq -r ".lambda.verify.commands[] | @base64" <./xilution.json)
execute_commands "${commands}"

echo "All Done!"
