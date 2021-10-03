#!/bin/bash -e

[ -z "$STAGE_NAME" ] && echo "Didn't find STAGE_NAME env var." && exit 1
[ -z "$CODEBUILD_SRC_DIR_SourceCode" ] && echo "Didn't find CODEBUILD_SRC_DIR_SourceCode env var." && exit 1
[ -z "$XILUTION_CONFIG" ] && echo "Didn't find XILUTION_CONFIG env var." && exit 1
[ -z "$PIPELINE_ID" ] && echo "Didn't find PIPELINE_ID env var." && exit 1
[ -z "$CLIENT_AWS_REGION" ] && echo "Didn't find CLIENT_AWS_REGION env var." && exit 1
[ -z "$PIPELINE_TYPE" ] && echo "Didn't find PIPELINE_TYPE env var." && exit 1

. ./scripts/common-functions.sh

stageName=${STAGE_NAME}
sourceDir=${CODEBUILD_SRC_DIR_SourceCode}
pipelineId=${PIPELINE_ID}
currentDir=$(pwd)
xilutionConfig=${XILUTION_CONFIG}

echo "stageName = ${stageName}"
echo "sourceDir = ${sourceDir}"
echo "pipelineId = ${pipelineId}"
echo "currentDir = ${currentDir}"
echo "xilutionConfig = ${xilutionConfig}"

stageNameLower=$(echo "${stageName}" | tr '[:upper:]' '[:lower:]')

echo "stageNameLower = ${stageNameLower}"

cd "${sourceDir}" || false

testDetails=$(echo "${xilutionConfig}" | base64 --decode | jq -r ".tests.${stageNameLower}[]? | @base64")

for testDetail in ${testDetails}; do
  testName=$(echo "${testDetail}" | base64 --decode | jq -r ".name?")
  echo "Running: ${testName}"
  commands=$(echo "${testDetail}" | base64 --decode | jq -r ".commands[]? | @base64")
  execute_commands "${commands}"
done

cd "${currentDir}" || false

echo "All Done!"
