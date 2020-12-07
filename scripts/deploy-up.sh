#!/bin/bash -ex

. ./scripts/common_functions.sh

sourceDir=${CODEBUILD_SRC_DIR_SourceCode}
currentDir=$(pwd)

cd "$sourceDir" || false

pipelineId=${FOX_PIPELINE_ID}
sourceVersion=${COMMIT_ID}
stackName="xilution-fox-${pipelineId:0:8}-trunk-stack"
sourceBucket="xilution-fox-${pipelineId:0:8}-source-code"
stageName=${STAGE_NAME}
stageNameLower=$(echo "${stageName}" | tr '[:upper:]' '[:lower:]')
layerName="xilution-fox-${pipelineId:0:8}-${stageNameLower}-lambda-layer"
layerZipFileName="${sourceVersion}-layer.zip"

echo "Getting the API ID"
query=".Stacks[0].Outputs | map(select(.ExportName == \"${stackName}-api\")) | .[] .OutputValue"
describeStacksResponse=$(aws cloudformation describe-stacks --stack-name "${stackName}")
apiId=$(echo "${describeStacksResponse}" | jq -r "${query}")
echo "The API ID is: ${apiId}"

echo "Releasing the API"
aws apigatewayv2 create-deployment \
  --api-id "${apiId}" \
  --stage-name "${stageNameLower}"

echo "Creating a new layer"
publishLayerVersionResponse=$(aws lambda publish-layer-version --layer-name "${layerName}" --content "S3Bucket=${sourceBucket},S3Key=${layerZipFileName}")
echo "${publishLayerVersionResponse}"
layerVersionArn=$(echo "${publishLayerVersionResponse}" | jq -r ".LayerVersionArn")
echo "New layer version arn is: ${layerVersionArn}"

functionName="xilution-fox-${pipelineId:0:8}-${stageNameLower}-lambda"
functionZipFileName="${sourceVersion}-function.zip"

echo "Updating the lambda to use the new layer"
aws lambda update-function-configuration \
  --function-name "${functionName}" \
  --layers "${layerVersionArn}"

echo "Updating the lambda function code"
aws lambda update-function-code \
  --function-name "${functionName}" \
  --s3-bucket "${sourceBucket}" \
  --s3-key "${functionZipFileName}"

cd "${currentDir}" || false

echo "All Done!"
