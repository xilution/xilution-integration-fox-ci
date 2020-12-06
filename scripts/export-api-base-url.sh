#!/bin/bash -ex

pipelineId=${FOX_PIPELINE_ID}
trunkStackName="xilution-fox-${pipelineId:0:8}-trunk-stack"
stageName=${STAGE_NAME}
stageNameLower=$(echo "${stageName}" | tr '[:upper:]' '[:lower:]')

jq_query=".Stacks[0].Outputs | map(select(.ExportName == \"${trunkStackName}-api-base-url\")) | .[] .OutputValue"
api_base_url=$(aws cloudformation describe-stacks --stack-name "${trunkStackName}" | jq -r "${jq_query}")

export API_BASE_URL="${api_base_url}/${stageNameLower}"

echo "All Done!"
