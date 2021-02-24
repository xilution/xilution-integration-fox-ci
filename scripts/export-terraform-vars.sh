#!/bin/bash -e

[ -z "$1" ] && echo "The first argument should be the pipeline phase (trunk or stage)." && exit 1
[ -z "$PIPELINE_TYPE" ] && echo "Didn't find PIPELINE_TYPE env var." && exit 1
[ -z "$XILUTION_CONFIG" ] && echo "Didn't find XILUTION_CONFIG env var." && exit 1

phase=${1}

export ADD_INFRA_TERRAFORM_PATH_STAGE=$(echo "${XILUTION_CONFIG}" | base64 --decode | jq -r ".additionalInfrastructure?.stage?.terraformModuleDir")
export ADD_INFRA_TERRAFORM_PATH_TRUNK=$(echo "${XILUTION_CONFIG}" | base64 --decode | jq -r ".additionalInfrastructure?.trunk?.terraformModuleDir")

if [[ "${PIPELINE_TYPE}" == "AWS_SMALL" ]]; then
  export TERRAFORM_PROVIDER="aws"
  export TERRAFORM_PATH="./terraform/${TERRAFORM_PROVIDER}/small/${phase}"
elif [[ "${PIPELINE_TYPE}" == "AWS_MEDIUM" ]]; then
  export TERRAFORM_PROVIDER="aws"
  export TERRAFORM_PATH="./terraform/${TERRAFORM_PROVIDER}/medium/${phase}"
else
  echo "Unrecognized pipeline type: ${PIPELINE_TYPE}"
  exit 1
fi
