#!/bin/bash -ex

direction=${1}
awsAccountId=${CLIENT_AWS_ACCOUNT}
pipelineId=${FOX_PIPELINE_ID}
stageName=${STAGE_NAME}
sourceVersion=${COMMIT_ID}

sourceDir=${CODEBUILD_SRC_DIR_SourceCode}
currentDir=$(pwd)
cd "${sourceDir}" || false
handler=$(jq -r ".handler" <./xilution.json)
runtime=$(jq -r ".runtime" <./xilution.json)
endpoints=$(jq -r ".api.endpoints[] | @base64" <./xilution.json)
cd "${currentDir}" || false
routeKeys=""
INDEX=0
for endpoint in ${endpoints}; do
  method=$(echo "${endpoint}" | base64 --decode | jq -r ".method")
  methodUpper=$(echo "${method}" | tr '[:lower:]' '[:upper:]')
  path=$(echo "${endpoint}" | base64 --decode | jq -r ".path")

  if [[ "${INDEX}" == 0 ]]; then
    routeKeys="\"${methodUpper} ${path}\""
  else
    routeKeys="${routeKeys}, \"${methodUpper} ${path}\""
  fi

  INDEX=${INDEX}+1
done
echo routeKeys = ${routeKeys}

terraform init \
  -backend-config="key=xilution-integration-fox/${pipelineId}/${stageName}/terraform.tfstate" \
  -backend-config="bucket=xilution-terraform-backend-state-bucket-${awsAccountId}" \
  -backend-config="dynamodb_table=xilution-terraform-backend-lock-table" \
  ./terraform/stage

if [[ ${direction} == "up"]]; then

  terraform plan \
    -var="organization_id=$XILUTION_ORGANIZATION_ID" \
    -var="coyote_pipeline_id=$COYOTE_PIPELINE_ID" \
    -var="stage_name=$STAGE_NAME" \
    -var="client_aws_account=$CLIENT_AWS_ACCOUNT" \
    -var="client_aws_region=$CLIENT_AWS_REGION" \
    -var="xilution_aws_account=$XILUTION_AWS_ACCOUNT" \
    -var="xilution_aws_region=$XILUTION_AWS_REGION" \
    -var="xilution_environment=$XILUTION_ENVIRONMENT" \
    -var="xilution_pipeline_type=$PIPELINE_TYPE" \
    -var="lambda_runtime=${runtime}" \
    -var="lambda_handler=${handler}" \
    -var="source_version=${sourceVersion}" \
    -var="route_keys=[${routeKeys}]" \
    ./terraform/stage

  terraform apply \
    -var="organization_id=$XILUTION_ORGANIZATION_ID" \
    -var="coyote_pipeline_id=$COYOTE_PIPELINE_ID" \
    -var="stage_name=$STAGE_NAME" \
    -var="client_aws_account=$CLIENT_AWS_ACCOUNT" \
    -var="client_aws_region=$CLIENT_AWS_REGION" \
    -var="xilution_aws_account=$XILUTION_AWS_ACCOUNT" \
    -var="xilution_aws_region=$XILUTION_AWS_REGION" \
    -var="xilution_environment=$XILUTION_ENVIRONMENT" \
    -var="xilution_pipeline_type=$PIPELINE_TYPE" \
    -var="lambda_runtime=${runtime}" \
    -var="lambda_handler=${handler}" \
    -var="source_version=${sourceVersion}" \
    -var="route_keys=[${routeKeys}]" \
    -auto-approve \
    ./terraform/stage

elif [[ ${direction} == "down"]]; then

  terraform destroy \
    -var="organization_id=$XILUTION_ORGANIZATION_ID" \
    -var="coyote_pipeline_id=$COYOTE_PIPELINE_ID" \
    -var="stage_name=$STAGE_NAME" \
    -var="client_aws_account=$CLIENT_AWS_ACCOUNT" \
    -var="client_aws_region=$CLIENT_AWS_REGION" \
    -var="xilution_aws_account=$XILUTION_AWS_ACCOUNT" \
    -var="xilution_aws_region=$XILUTION_AWS_REGION" \
    -var="xilution_environment=$XILUTION_ENVIRONMENT" \
    -var="xilution_pipeline_type=$PIPELINE_TYPE" \
    -var="lambda_runtime=${runtime}" \
    -var="lambda_handler=${handler}" \
    -var="source_version=${sourceVersion}" \
    -var="route_keys=[${routeKeys}]" \
    -auto-approve \
    ./terraform/stage

fi

echo "All Done!"
