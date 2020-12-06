#!/bin/bash -ex

. ./scripts/common_functions.sh

pipelineId=${FOX_PIPELINE_ID}
trunkStackName="xilution-fox-${pipelineId:0:8}-trunk-stack"

delete_cloudformation_stack "${trunkStackName}"

echo "All Done!"
