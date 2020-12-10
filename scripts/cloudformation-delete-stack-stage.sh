#!/bin/bash -ex

. ./scripts/common_functions.sh

sourceDir=${CODEBUILD_SRC_DIR_SourceCode}
currentDir=$(pwd)
cd "$sourceDir" || false
endpoints=$(jq -r ".api.endpoints[] | @base64" <./xilution.json)
cd "${currentDir}" || false

pipelineId=${FOX_PIPELINE_ID}
stageName=${STAGE_NAME}
stageNameLower=$(echo "${stageName}" | tr '[:upper:]' '[:lower:]')

for endpoint in ${endpoints}; do

  endpointId=$(echo "${endpoint}" | base64 --decode | jq -r ".id")
  routeStackName="xilution-fox-${pipelineId:0:8}-stage-${stageNameLower}-${endpointId}-stack"
  delete_cloudformation_stack "${routeStackName}"
done

apiLambdaStackName="xilution-fox-${pipelineId:0:8}-stage-${stageNameLower}-api-lambda-stack"

delete_cloudformation_stack "${apiLambdaStackName}"

echo "All Done!"
