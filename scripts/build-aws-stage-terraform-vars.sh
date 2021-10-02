#!/bin/bash -e

[ -z "$XILUTION_CONFIG" ] && echo "Didn't find XILUTION_CONFIG env var." && exit 1
[ -z "$XILUTION_ORGANIZATION_ID" ] && echo "Didn't find XILUTION_ORGANIZATION_ID env var." && exit 1
[ -z "$GAZELLE_PIPELINE_ID" ] && echo "Didn't find GAZELLE_PIPELINE_ID env var." && exit 1
[ -z "$FOX_PIPELINE_ID" ] && echo "Didn't find FOX_PIPELINE_ID env var." && exit 1
[ -z "$PIPELINE_TYPE" ] && echo "Didn't find PIPELINE_TYPE env var." && exit 1
[ -z "$CLIENT_AWS_ACCOUNT" ] && echo "Didn't find CLIENT_AWS_ACCOUNT env var." && exit 1
[ -z "$CLIENT_AWS_REGION" ] && echo "Didn't find CLIENT_AWS_REGION env var." && exit 1
[ -z "$XILUTION_AWS_ACCOUNT" ] && echo "Didn't find XILUTION_AWS_ACCOUNT env var." && exit 1
[ -z "$XILUTION_AWS_REGION" ] && echo "Didn't find XILUTION_AWS_REGION env var." && exit 1
[ -z "$XILUTION_ENVIRONMENT" ] && echo "Didn't find XILUTION_ENVIRONMENT env var." && exit 1
[ -z "$STAGE_NAME" ] && echo "Didn't find STAGE_NAME env var." && exit 1
[ -z "$COMMIT_ID" ] && echo "Didn't find COMMIT_ID env var." && exit 1
# [ -z "$DOMAIN" ] && echo "Didn't find DOMAIN env var." && exit 1

handler=$(echo "${XILUTION_CONFIG}" | base64 --decode | jq -r ".lambda.handler")
runtime=$(echo "${XILUTION_CONFIG}" | base64 --decode | jq -r ".lambda.runtime")
publicEndpoints=$(echo "${XILUTION_CONFIG}" | base64 --decode | jq -r ".api.endpoints.public")
privateEndpoints=$(echo "${XILUTION_CONFIG}" | base64 --decode | jq -r ".api.endpoints.private")
jwtAuthorizer=$(echo "${XILUTION_CONFIG}" | base64 --decode | jq -r ".api.jwtAuthorizer")

echo "XILUTION_ORGANIZATION_ID: ${XILUTION_ORGANIZATION_ID}"
echo "GAZELLE_PIPELINE_ID: ${GAZELLE_PIPELINE_ID}"
echo "FOX_PIPELINE_ID: ${FOX_PIPELINE_ID}"
echo "PIPELINE_TYPE: ${PIPELINE_TYPE}"
echo "CLIENT_AWS_ACCOUNT: ${CLIENT_AWS_ACCOUNT}"
echo "CLIENT_AWS_REGION: ${CLIENT_AWS_REGION}"
echo "XILUTION_AWS_ACCOUNT: ${XILUTION_AWS_ACCOUNT}"
echo "XILUTION_AWS_REGION: ${XILUTION_AWS_REGION}"
echo "XILUTION_ENVIRONMENT: ${XILUTION_ENVIRONMENT}"
echo "STAGE_NAME: ${STAGE_NAME}"
echo "COMMIT_ID: ${COMMIT_ID}"
echo "DOMAIN: ${DOMAIN}"
echo "handler: ${handler}"
echo "runtime: ${runtime}"
echo "publicEndpoints: ${publicEndpoints}"
echo "privateEndpoints: ${privateEndpoints}"
echo "jwtAuthorizer: ${jwtAuthorizer}"

cat <<EOF >./tfvars.json
{
  "organization_id": "$XILUTION_ORGANIZATION_ID",
  "gazelle_pipeline_id": "$GAZELLE_PIPELINE_ID",
  "fox_pipeline_id": "$FOX_PIPELINE_ID",
  "pipeline_id": "$FOX_PIPELINE_ID",
  "pipeline_type": "$PIPELINE_TYPE",
  "client_aws_account": "$CLIENT_AWS_ACCOUNT",
  "client_aws_region": "$CLIENT_AWS_REGION",
  "xilution_aws_account": "$XILUTION_AWS_ACCOUNT",
  "xilution_aws_region": "$XILUTION_AWS_REGION",
  "xilution_environment": "$XILUTION_ENVIRONMENT",
  "stage_name": "$STAGE_NAME",
  "domain": "$DOMAIN",
  "source_version": "$COMMIT_ID",
  "lambda_handler": "$handler",
  "lambda_runtime": "$runtime",
  "public_endpoints": $publicEndpoints,
  "private_endpoints": $privateEndpoints,
  "jwt_authorizer": $jwtAuthorizer
}
EOF
