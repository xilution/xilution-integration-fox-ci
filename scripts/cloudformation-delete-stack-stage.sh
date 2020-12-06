#!/bin/bash -ex

. ./scripts/common_functions.sh

sourceDir=${CODEBUILD_SRC_DIR_SourceCode}
currentDir=$(pwd)

cd "$sourceDir" || false

pipelineId=${FOX_PIPELINE_ID}
stageName=${STAGE_NAME}
stageNameLower=$(echo "${stageName}" | tr '[:upper:]' '[:lower:]')
stageStackName="xilution-fox-${pipelineId:0:8}-stage-${stageNameLower}-stack"
endpoints=$(jq -r ".api.endpoints[] | @base64" <./xilution.json)

for endpoint in ${endpoints}; do

  endpointId=$(echo "${endpoint}" | base64 --decode | jq -r ".id")
  endpointStackName="xilution-fox-${pipelineId:0:8}-stage-${stageNameLower}-${endpointId}-stack"
  delete_cloudformation_stack "${endpointStackName}"
done

delete_cloudformation_stack "${stageStackName}"

cd "${currentDir}" || false

echo "All Done!"
