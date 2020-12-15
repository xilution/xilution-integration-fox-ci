#!/bin/bash -ex

pipelineId=${FOX_PIPELINE_ID}
stageName=${STAGE_NAME}
stageNameLower=$(echo "${stageName}" | tr '[:upper:]' '[:lower:]')
apiLambdaStackName="xilution-fox-${pipelineId}-stage-${stageNameLower}-api-lambda-stack"

query=".Stacks[0].Outputs | map(select(.ExportName == \"${apiLambdaStackName}-api-base-url\")) | .[] .OutputValue"
api_base_url=$(aws cloudformation describe-stacks --stack-name "${apiLambdaStackName}" | jq -r "${query}")

export API_BASE_URL="${api_base_url}"

echo "All Done!"
