#!/bin/bash -ex

. ./scripts/common_functions.sh

sourceDir=${CODEBUILD_SRC_DIR_SourceCode}
currentDir=$(pwd)
cd "${sourceDir}" || false
handler=$(jq -r ".handler" <./xilution.json)
runtime=$(jq -r ".runtime" <./xilution.json)
endpoints=$(jq -r ".api.endpoints[] | @base64" <./xilution.json)
cd "${currentDir}" || false

pipelineId=${FOX_PIPELINE_ID}
trunkStackName="xilution-fox-${pipelineId:0:8}-trunk-stack"
stageName=${STAGE_NAME}
stageNameLower=$(echo "${stageName}" | tr '[:upper:]' '[:lower:]')
apiLambdaStackName="xilution-fox-${pipelineId:0:8}-stage-${stageNameLower}-api-lambda-stack"
sourceVersion=${COMMIT_ID}
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
    \"ParameterKey\":\"Handler\",
    \"ParameterValue\":\"${handler}\"
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
templateBody="file://./cloudformation/stage/api-lambda.yaml"

create_or_update_cloudformation_stack "${pipelineId}" "${apiLambdaStackName}" "${parameters}" "${templateBody}"

echo "All Done!"
