#!/bin/bash -e

direction=${1}
awsAccountId=${CLIENT_AWS_ACCOUNT}
pipelineId=${FOX_PIPELINE_ID}
stageName=${STAGE_NAME}
sourceVersion=${COMMIT_ID}

sourceDir=${CODEBUILD_SRC_DIR_SourceCode}
currentDir=$(pwd)
cd "${sourceDir}" || false
handler=$(jq -r ".lambda.handler" <./xilution.json)
runtime=$(jq -r ".lambda.runtime" <./xilution.json)
publicEndpoints=$(jq -r ".api.endpoints.public" <./xilution.json)
privateEndpoints=$(jq -r ".api.endpoints.private" <./xilution.json)
jwtAuthorizer=$(jq -r ".api.jwtAuthorizer" <./xilution.json)
cd "${currentDir}" || false

terraform init -no-color \
  -backend-config="key=xilution-integration-fox/${pipelineId}/${stageName}/terraform.tfstate" \
  -backend-config="bucket=xilution-terraform-backend-state-bucket-${awsAccountId}" \
  -backend-config="dynamodb_table=xilution-terraform-backend-lock-table" \
  ./terraform/stage

if [[ "${direction}" == "up" ]]; then

  terraform plan -no-color \
    -var="organization_id=$XILUTION_ORGANIZATION_ID" \
    -var="gazelle_pipeline_id=$GAZELLE_PIPELINE_ID" \
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
    -var="public_endpoints=${publicEndpoints}" \
    -var="private_endpoints=${privateEndpoints}" \
    -var="jwt_authorizer=${jwtAuthorizer}" \
    ./terraform/stage

  terraform apply -no-color \
    -var="organization_id=$XILUTION_ORGANIZATION_ID" \
    -var="gazelle_pipeline_id=$GAZELLE_PIPELINE_ID" \
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
    -var="public_endpoints=${publicEndpoints}" \
    -var="private_endpoints=${privateEndpoints}" \
    -var="jwt_authorizer=${jwtAuthorizer}" \
    -auto-approve \
    ./terraform/stage

elif [[ "${direction}" == "down" ]]; then

  terraform destroy -no-color \
    -var="organization_id=$XILUTION_ORGANIZATION_ID" \
    -var="gazelle_pipeline_id=$GAZELLE_PIPELINE_ID" \
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
    -var="public_endpoints=${publicEndpoints}" \
    -var="private_endpoints=${privateEndpoints}" \
    -var="jwt_authorizer=${jwtAuthorizer}" \
    -auto-approve \
    ./terraform/stage

fi

echo "All Done!"
