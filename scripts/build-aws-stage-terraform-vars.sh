#!/bin/bash -e

[ -z "$XILUTION_CONFIG" ] && echo "Didn't find XILUTION_CONFIG env var." && exit 1

handler=$(echo "${XILUTION_CONFIG}" | base64 --decode | jq -r ".lambda.handler")
runtime=$(echo "${XILUTION_CONFIG}" | base64 --decode | jq -r ".lambda.runtime")
publicEndpoints=$(echo "${XILUTION_CONFIG}" | base64 --decode | jq -r ".api.endpoints.public")
privateEndpoints=$(echo "${XILUTION_CONFIG}" | base64 --decode | jq -r ".api.endpoints.private")
jwtAuthorizer=$(echo "${XILUTION_CONFIG}" | base64 --decode | jq -r ".api.jwtAuthorizer")

cat <<EOF >./tfvars.json
{
  "organization_id": "$XILUTION_ORGANIZATION_ID",
  "gazelle_pipeline_id": "$GAZELLE_PIPELINE_ID",
  "fox_pipeline_id": "$FOX_PIPELINE_ID",
  "client_aws_account": "$CLIENT_AWS_ACCOUNT",
  "client_aws_region": "$CLIENT_AWS_REGION",
  "xilution_aws_account": "$XILUTION_AWS_ACCOUNT",
  "xilution_aws_region": "$XILUTION_AWS_REGION",
  "xilution_environment": "$XILUTION_ENVIRONMENT",
  "pipeline_type": "$PIPELINE_TYPE",
  "stage_name": "$STAGE_NAME",
  "lambda_runtime": "${runtime}",
  "lambda_handler": "${handler}",
  "source_version": "${sourceVersion}",
  "public_endpoints": "${publicEndpoints}",
  "private_endpoints": "${privateEndpoints}",
  "jwt_authorizer": "${jwtAuthorizer}"
}
EOF
