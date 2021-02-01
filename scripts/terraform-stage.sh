#!/bin/bash -e

direction=${1}
pipelineId=${FOX_PIPELINE_ID}
stageName=${STAGE_NAME}
sourceVersion=${COMMIT_ID}

sourceDir=${CODEBUILD_SRC_DIR_SourceCode}
currentDir=$(pwd)
cd "${sourceDir}" || false
handler=$(jq -r ".handler" <./xilution.json)
runtime=$(jq -r ".runtime" <./xilution.json)
api=$(jq -r ".api" <./xilution.json)

terraform init \
  -backend-config="key=xilution-integration-fox/${pipelineId}/${stageName}/terraform.tfstate" \
  -backend-config="bucket=xilution-terraform-backend-state-bucket-${CLIENT_AWS_ACCOUNT}" \
  -backend-config="dynamodb_table=xilution-terraform-backend-lock-table" \
  ./terraform/stage

if [[ "${direction}" == "up" ]]; then

  terraform plan \
    -var="organization_id=$XILUTION_ORGANIZATION_ID" \
    -var="fox_pipeline_id=$FOX_PIPELINE_ID" \
    -var="client_aws_account=$CLIENT_AWS_ACCOUNT" \
    -var="client_aws_region=$CLIENT_AWS_REGION" \
    -var="xilution_aws_account=$XILUTION_AWS_ACCOUNT" \
    -var="xilution_aws_region=$XILUTION_AWS_REGION" \
    -var="xilution_environment=$XILUTION_ENVIRONMENT" \
    -var="xilution_pipeline_type=$PIPELINE_TYPE" \
    -var="stage_name=$STAGE_NAME" \
    -var="lambda_runtime=${runtime}" \
    -var="lambda_handler=${handler}" \
    -var="source_version=${sourceVersion}" \
    -var="api=${api}" \
    ./terraform/stage

  terraform apply \
    -var="organization_id=$XILUTION_ORGANIZATION_ID" \
    -var="fox_pipeline_id=$FOX_PIPELINE_ID" \
    -var="client_aws_account=$CLIENT_AWS_ACCOUNT" \
    -var="client_aws_region=$CLIENT_AWS_REGION" \
    -var="xilution_aws_account=$XILUTION_AWS_ACCOUNT" \
    -var="xilution_aws_region=$XILUTION_AWS_REGION" \
    -var="xilution_environment=$XILUTION_ENVIRONMENT" \
    -var="xilution_pipeline_type=$PIPELINE_TYPE" \
    -var="stage_name=$STAGE_NAME" \
    -var="lambda_runtime=${runtime}" \
    -var="lambda_handler=${handler}" \
    -var="source_version=${sourceVersion}" \
    -var="api=${api}" \
    -auto-approve \
    ./terraform/stage

elif [[ "${direction}" == "down" ]]; then

  terraform destroy \
    -var="organization_id=$XILUTION_ORGANIZATION_ID" \
    -var="fox_pipeline_id=$FOX_PIPELINE_ID" \
    -var="client_aws_account=$CLIENT_AWS_ACCOUNT" \
    -var="client_aws_region=$CLIENT_AWS_REGION" \
    -var="xilution_aws_account=$XILUTION_AWS_ACCOUNT" \
    -var="xilution_aws_region=$XILUTION_AWS_REGION" \
    -var="xilution_environment=$XILUTION_ENVIRONMENT" \
    -var="xilution_pipeline_type=$PIPELINE_TYPE" \
    -var="stage_name=$STAGE_NAME" \
    -var="lambda_runtime=${runtime}" \
    -var="lambda_handler=${handler}" \
    -var="source_version=${sourceVersion}" \
    -var="api=${api}" \
    -auto-approve \
    ./terraform/stage

fi

echo "All Done!"
