#!/bin/bash -ex

direction=${1}
sourceDir=${CODEBUILD_SRC_DIR_SourceCode}
currentDir=$(pwd)
cd "${sourceDir}" || false
terraformModuleDir=$(jq -r ".additionalInfrastructure?.stage?.terraformModuleDir" <./xilution.json)

echo "terraformModuleDir = ${terraformModuleDir}"

if [[ "${terraformModuleDir}" != "null" ]]; then

  terraform init \
    -backend-config="key=xilution-integration-fox/${FOX_PIPELINE_ID}/${STAGE_NAME}/additional-infrastructure.tfstate" \
    -backend-config="bucket=xilution-terraform-backend-state-bucket-${CLIENT_AWS_ACCOUNT}" \
    -backend-config="dynamodb_table=xilution-terraform-backend-lock-table" \
    "${terraformModuleDir}"

  if [[ ${direction} == "up"]]; then

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
      "${terraformModuleDir}"

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
      -auto-approve \
      "${terraformModuleDir}"

  elif [[ ${direction} == "down"]]; then

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
      -auto-approve \
      "${terraformModuleDir}"

  fi

else
  echo "terraformModuleDir not found."
fi

cd "${currentDir}" || false

echo "All Done!"
