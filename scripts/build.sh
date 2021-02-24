#!/bin/bash -e

[ -z "$PIPELINE_ID" ] && echo "Didn't find PIPELINE_ID env var." && exit 1
[ -z "$CODEBUILD_SRC_DIR_SourceCode" ] && echo "Didn't find CODEBUILD_SRC_DIR_SourceCode env var." && exit 1
[ -z "$COMMIT_ID" ] && echo "Didn't find COMMIT_ID env var." && exit 1
[ -z "$XILUTION_CONFIG" ] && echo "Didn't find XILUTION_CONFIG env var." && exit 1

. ./scripts/common-functions.sh

pipelineId=${PIPELINE_ID}
sourceDir=${CODEBUILD_SRC_DIR_SourceCode}
currentDir=$(pwd)
sourceVersion=${COMMIT_ID}

echo "pipelineId = ${pipelineId}"
echo "sourceDir = ${sourceDir}"
echo "sourceVersion = ${sourceVersion}"

cd "${sourceDir}" || false

buildDir=$(echo "${XILUTION_CONFIG}" | base64 --decode | jq -r ".lambda.build.src.buildDir")
if [[ "${buildDir}" == "null" ]]; then
  echo "Unable to find build directory."
  exit 1
fi

commands=$(echo "${XILUTION_CONFIG}" | base64 --decode | jq -r ".lambda.build.src.commands[] | @base64")
execute_commands "${commands}"

functionZipFileName="${sourceVersion}-function.zip"
cd "${buildDir}" || false
zip -r "${sourceDir}/${functionZipFileName}" .
cd "${sourceDir}" || false

aws s3 cp "./${functionZipFileName}" "s3://xilution-fox-${pipelineId:0:8}-source-code/"
openssl dgst -sha256 -binary "./${functionZipFileName}" | openssl enc -base64 > "./${functionZipFileName}.sha256"
aws s3 cp "./${functionZipFileName}.sha256" "s3://xilution-fox-${pipelineId:0:8}-source-code/"

layerDir=$(echo "${XILUTION_CONFIG}" | base64 --decode | jq -r ".lambda.build.layer.layerDir")
if [[ "${layerDir}" == "null" ]]; then
  echo "Unable to find layer directory."
  exit 1
fi

commands=$(echo "${XILUTION_CONFIG}" | base64 --decode | jq -r ".lambda.build.layer.commands[] | @base64")
execute_commands "${commands}"

layerZipFileName="${sourceVersion}-layer.zip"
zip -r "${sourceDir}/${layerZipFileName}" "${layerDir}"

aws s3 cp "./${layerZipFileName}" "s3://xilution-fox-${pipelineId:0:8}-source-code/"
openssl dgst -sha256 -binary "./${layerZipFileName}" | openssl enc -base64 > "./${layerZipFileName}.sha256"
aws s3 cp "./${layerZipFileName}.sha256" "s3://xilution-fox-${pipelineId:0:8}-source-code/"

cd "${currentDir}" || false

echo "All Done!"
