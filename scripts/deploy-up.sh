#!/bin/bash -e

[ -z "$PIPELINE_ID" ] && echo "Didn't find PIPELINE_ID env var." && exit 1
[ -z "$COMMIT_ID" ] && echo "Didn't find COMMIT_ID env var." && exit 1
[ -z "$STAGE_NAME" ] && echo "Didn't find STAGE_NAME env var." && exit 1

pipelineId=${PIPELINE_ID}
sourceVersion=${COMMIT_ID}
stageName=${STAGE_NAME}
pipelineIdShort=$(echo "${pipelineId}" | cut -c1-8)
stageNameLower=$(echo "${stageName}" | tr '[:upper:]' '[:lower:]')

sourceBucket="xilution-fox-${pipelineIdShort}-source-code"
layerName="xilution-fox-${pipelineId:0:8}-${stageNameLower}-lambda-layer"
layerZipFileName="${sourceVersion}-layer.zip"

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

echo "Waiting for new layer to update"
aws lambda wait function-updated \
  --function-name "${functionName}"

echo "Updating the lambda function code"
aws lambda update-function-code \
  --function-name "${functionName}" \
  --s3-bucket "${sourceBucket}" \
  --s3-key "${functionZipFileName}"

echo "Waiting for function code to update"
aws lambda wait function-updated \
  --function-name "${functionName}"

echo "All Done!"
