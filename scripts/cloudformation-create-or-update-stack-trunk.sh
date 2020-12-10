#!/bin/bash -ex

. ./scripts/common_functions.sh

pipelineId=${FOX_PIPELINE_ID}
trunkStackName="xilution-fox-${pipelineId:0:8}-trunk-stack"
parameters="[
  {
    \"ParameterKey\":\"PipelineId\",
    \"ParameterValue\":\"${pipelineId:0:8}\"
  }
]"

templateBody="file://./cloudformation/trunk/template.yaml"

create_or_update_cloudformation_stack "${pipelineId}" "${trunkStackName}" "${parameters}" "${templateBody}"

echo "All Done!"
