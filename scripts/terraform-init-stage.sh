#!/bin/bash

awsAccountId=${1}
pipelineId=${2}
stageName=${3}

terraform init \
  -backend-config="key=xilution-content-delivery-coyote/${pipelineId}/${stageName}/terraform.tfstate" \
  -backend-config="bucket=xilution-terraform-backend-state-bucket-${awsAccountId}" \
  -backend-config="dynamodb_table=xilution-terraform-backend-lock-table" \
  ./terraform/stage
