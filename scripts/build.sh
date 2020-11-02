#!/bin/bash -ex

. ./scripts/common_functions.sh

pipelineId=${FOX_PIPELINE_ID}
sourceDir=${CODEBUILD_SRC_DIR_SourceCode}
sourceVersion=${CODEBUILD_SOURCE_VERSION_SourceCode}

echo env

echo "pipelineId = ${pipelineId}"
echo "sourceDir = ${sourceDir}"
echo "sourceVersion = ${sourceVersion}"

cd "${sourceDir}" || false

buildDir=$(jq -r ".build.buildDir" <./xilution.json)
if [[ "${buildDir}" == "null" ]]; then
  echo "Unable to find build directory."
  exit 1
fi

commands=$(jq -r ".build.commands[] | @base64" <./xilution.json)
execute_commands "${commands}"

functionZipFileName="${sourceVersion}-function.zip"
cd "${buildDir}" || false
zip -r "${sourceDir}/${functionZipFileName}" .
cd "${sourceDir}" || false

aws s3 cp "./${functionZipFileName}" "s3://xilution-fox-${pipelineId:0:8}-source-code/"

layerDir=$(jq -r ".layer.layerDir" <./xilution.json)
if [[ "${layerDir}" == "null" ]]; then
  echo "Unable to find layer directory."
  exit 1
fi

commands=$(jq -r ".layer.commands[] | @base64" <./xilution.json)
execute_commands "${commands}"

layerZipFileName="${sourceVersion}-layer.zip"
zip -r "${sourceDir}/${layerZipFileName}" "${layerDir}"

aws s3 cp "./${layerZipFileName}" "s3://xilution-fox-${pipelineId:0:8}-source-code/"
