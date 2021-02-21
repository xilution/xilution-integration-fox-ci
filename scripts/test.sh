#!/bin/bash -e

. ./scripts/common_functions.sh

sourceDir=${CODEBUILD_SRC_DIR_SourceCode}
pipelineId=${FOX_PIPELINE_ID}
stageName=${STAGE_NAME}
stageNameLower=$(echo "${stageName}" | tr '[:upper:]' '[:lower:]')
apiName="xilution-fox-${pipelineId:0:8}-${stageNameLower}-api"

query=".Items | map(select(.Name == \"${apiName}\")) | .[] .ApiEndpoint"
apiBaseUrl=$(aws apigatewayv2 get-apis | jq -r "${query}")


cd "${sourceDir}" || false

testDetails=$(jq -r ".tests.${stageName}[] | @base64" <./xilution.json)

for testDetail in ${testDetails}; do
  wait_for_site_to_be_ready "${apiBaseUrl}"
  testName=$(echo "${testDetail}" | base64 --decode | jq -r ".name?")
  echo "Running: ${testName}"
  commands=$(echo "${testDetail}" | base64 --decode | jq -r ".commands[]? | @base64")
  execute_commands "${commands}"
done

echo "All Done!"
