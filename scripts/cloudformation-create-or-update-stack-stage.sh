#!/bin/bash -ex

. ./scripts/common_functions.sh

sourceDir=${CODEBUILD_SRC_DIR_SourceCode}
currentDir=$(pwd)

cd "$sourceDir" || false

pipelineId=${FOX_PIPELINE_ID}
trunkStackName="xilution-fox-${pipelineId:0:8}-trunk-stack"
stageName=${STAGE_NAME}
stageNameLower=$(echo "${stageName}" | tr '[:upper:]' '[:lower:]')
stageStackName="xilution-fox-${pipelineId:0:8}-stage-${stageNameLower}-stack"
runtime=$(jq -r ".runtime" <./xilution.json)
sourceVersion=${CODEBUILD_SOURCE_VERSION_SourceCode}
parameters="[
  {
    \"ParameterKey\":\"PipelineId\",
    \"ParameterValue\":\"${pipelineId:0:8}\"
  },
  {
    \"ParameterKey\":\"StageName\",
    \"ParameterValue\":\"${stageNameLower}\"
  },
  {
    \"ParameterKey\":\"SourceVersion\",
    \"ParameterValue\":\"${sourceVersion}\"
  },
  {
    \"ParameterKey\":\"Runtime\",
    \"ParameterValue\":\"${runtime}\"
  },
  {
    \"ParameterKey\":\"TrunkStackName\",
    \"ParameterValue\":\"${trunkStackName}\"
  }
]"
templateBody="file://./cloudformation/stage/lambda.yaml"

cd "${currentDir}" || false

create_or_update_cloudformation_stack "${pipelineId}" "${stageStackName}" "${parameters}" "${templateBody}"

cd "$sourceDir" || false

endpoints=$(jq -r ".api.endpoints[] | @base64" <./xilution.json)

for endpoint in ${endpoints}; do

  endpointId=$(echo "${endpoint}" | base64 --decode | jq -r ".id")
  method=$(echo "${endpoint}" | base64 --decode | jq -r ".method")
  methodUpper=$(echo "${method}" | tr '[:lower:]' '[:upper:]')
  path=$(echo "${endpoint}" | base64 --decode | jq -r ".path")
  handler=$(echo "${endpoint}" | base64 --decode | jq -r ".function.handler")
  endpointStackName="xilution-fox-${pipelineId:0:8}-stage-${stageNameLower}-${endpointId}-stack"
  parameters="[
    {
      \"ParameterKey\":\"PipelineId\",
      \"ParameterValue\":\"${pipelineId:0:8}\"
    },
    {
      \"ParameterKey\":\"StageName\",
      \"ParameterValue\":\"${stageNameLower}\"
    },
    {
      \"ParameterKey\":\"EndpointId\",
      \"ParameterValue\":\"${endpointId}\"
    },
    {
      \"ParameterKey\":\"SourceVersion\",
      \"ParameterValue\":\"${sourceVersion}\"
    },
    {
      \"ParameterKey\":\"Handler\",
      \"ParameterValue\":\"${handler}\"
    },
    {
      \"ParameterKey\":\"Runtime\",
      \"ParameterValue\":\"${runtime}\"
    },
    {
      \"ParameterKey\":\"Method\",
      \"ParameterValue\":\"${methodUpper}\"
    },
    {
      \"ParameterKey\":\"Path\",
      \"ParameterValue\":\"${path}\"
    },
    {
      \"ParameterKey\":\"TrunkStackName\",
      \"ParameterValue\":\"${trunkStackName}\"
    },
    {
      \"ParameterKey\":\"StageStackName\",
      \"ParameterValue\":\"${stageStackName}\"
    }
  ]"
  templateBody="file://./cloudformation/stage/api.yaml"

  cd "${currentDir}" || false

  create_or_update_cloudformation_stack "${pipelineId}" "${endpointStackName}" "${parameters}" "${templateBody}"
done
