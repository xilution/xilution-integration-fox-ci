#!/bin/bash -ex

awsAccountId=${CLIENT_AWS_ACCOUNT}
pipelineId=${FOX_PIPELINE_ID}

terraform init \
  -backend-config="key=xilution-integration-fox/${pipelineId}/terraform.tfstate" \
  -backend-config="bucket=xilution-terraform-backend-state-bucket-${awsAccountId}" \
  -backend-config="dynamodb_table=xilution-terraform-backend-lock-table" \
  ./terraform/trunk

echo "All Done!"
