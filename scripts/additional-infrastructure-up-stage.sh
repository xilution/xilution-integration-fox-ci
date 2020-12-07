#!/bin/bash -ex

sourceDir=${CODEBUILD_SRC_DIR_SourceCode}

cd "$sourceDir" || false

terraformModuleDir=$(jq -r ".additionalInfrastructure?.stage?.terraformModuleDir" <./xilution.json)

echo "terraformModuleDir = ${terraformModuleDir}"

if [[ "${terraformModuleDir}" != "null" ]]; then
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
else
  echo "terraformModuleDir not found."
fi

cd "${currentDir}" || false

echo "All Done!"
