#!/bin/bash -ex

. ./scripts/common_functions.sh

sourceDir=${CODEBUILD_SRC_DIR_SourceCode}
currentDir=$(pwd)

cd "$sourceDir" || false

pipelineId=${FOX_PIPELINE_ID}
sourceVersion=${COMMIT_ID}
stageName=${STAGE_NAME}
stageNameLower=$(echo "${stageName}" | tr '[:upper:]' '[:lower:]')
sourceBucket="xilution-fox-${pipelineId}-source-code"
layerName="xilution-fox-${pipelineId}-${stageNameLower}-lambda-layer"
layerZipFileName="${sourceVersion}-layer.zip"

echo "Creating a new layer"
publishLayerVersionResponse=$(aws lambda publish-layer-version --layer-name "${layerName}" --content "S3Bucket=${sourceBucket},S3Key=${layerZipFileName}")
echo "${publishLayerVersionResponse}"
layerVersionArn=$(echo "${publishLayerVersionResponse}" | jq -r ".LayerVersionArn")
echo "New layer version arn is: ${layerVersionArn}"

functionName="xilution-fox-${pipelineId}-${stageNameLower}-lambda"
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
