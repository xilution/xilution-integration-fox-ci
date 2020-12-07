#!/bin/bash -ex

awsAccountId=${CLIENT_AWS_ACCOUNT}
pipelineId=${FOX_PIPELINE_ID}
stageName=${STAGE_NAME}

terraform init \
  -backend-config="key=xilution-integration-fox/${pipelineId}/${stageName}/terraform.tfstate" \
  -backend-config="bucket=xilution-terraform-backend-state-bucket-${awsAccountId}" \
  -backend-config="dynamodb_table=xilution-terraform-backend-lock-table" \
  ./terraform/stage
