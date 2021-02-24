#!/bin/bash -e

[ -z "$1" ] && echo "The first argument should product name." && exit 1
[ -z "$PIPELINE_ID" ] && echo "Didn't find PIPELINE_ID env var." && exit 1

productName=${1}
pipelineId=${PIPELINE_ID}

aws s3 rm "s3://xilution-${productName}-${pipelineId:0:8}-source-code" --include "*" --recursive

echo "All Done!"
