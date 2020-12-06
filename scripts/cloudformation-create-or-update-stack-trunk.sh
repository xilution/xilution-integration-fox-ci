#!/bin/bash -ex

. ./scripts/common_functions.sh

sourceDir=${CODEBUILD_SRC_DIR_SourceCode}
currentDir=$(pwd)
cd "$sourceDir" || false

pipelineId=${FOX_PIPELINE_ID}
stackName="xilution-fox-${pipelineId:0:8}-trunk-stack"
parameters="[
  {
    \"ParameterKey\":\"PipelineId\",
    \"ParameterValue\":\"${pipelineId:0:8}\"
  }
]"

templateBody="file://./cloudformation/trunk/template.yaml"

cd "${currentDir}" || false

create_or_update_cloudformation_stack "${pipelineId}" "${stackName}" "${parameters}" "${templateBody}"

echo "All Done!"
