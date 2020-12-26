#!/bin/bash -e

pipelineId=${FOX_PIPELINE_ID}
stageName=${STAGE_NAME}
stageNameLower=$(echo "${stageName}" | tr '[:upper:]' '[:lower:]')
apiName="xilution-fox-${pipelineId:0:8}-${stageNameLower}-api"

query=".Items | map(select(.Name == \"${apiName}\")) | .[] .ApiEndpoint"
api_base_url=$(aws apigatewayv2 get-apis | jq -r "${query}")

export API_BASE_URL="${api_base_url}"

echo "All Done!"
