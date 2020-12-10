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

for endpoint in ${endpoints}; do

  method=$(echo "${endpoint}" | base64 --decode | jq -r ".method")
  methodUpper=$(echo "${method}" | tr '[:lower:]' '[:upper:]')
  path=$(echo "${endpoint}" | base64 --decode | jq -r ".path")
  endpointId=$(echo "${endpoint}" | base64 --decode | jq -r ".id")
  routeStackName="xilution-fox-${pipelineId:0:8}-stage-${stageNameLower}-endpoint-${endpointId}-route-stack"
  parameters="[
    {
      \"ParameterKey\":\"Method\",
      \"ParameterValue\":\"${methodUpper}\"
    },
    {
      \"ParameterKey\":\"Path\",
      \"ParameterValue\":\"${path}\"
    },
    {
      \"ParameterKey\":\"ApiLambdaStackName\",
      \"ParameterValue\":\"${apiLambdaStackName}\"
    }
  ]"
  templateBody="file://./cloudformation/stage/route.yaml"

  create_or_update_cloudformation_stack "${pipelineId}" "${routeStackName}" "${parameters}" "${templateBody}"
done

echo "All Done!"
