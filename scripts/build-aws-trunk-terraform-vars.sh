#!/bin/bash -e

[ -z "$XILUTION_ORGANIZATION_ID" ] && echo "Didn't find XILUTION_ORGANIZATION_ID env var." && exit 1
[ -z "$GAZELLE_PIPELINE_ID" ] && echo "Didn't find GAZELLE_PIPELINE_ID env var." && exit 1
[ -z "$FOX_PIPELINE_ID" ] && echo "Didn't find FOX_PIPELINE_ID env var." && exit 1
[ -z "$PIPELINE_TYPE" ] && echo "Didn't find PIPELINE_TYPE env var." && exit 1
[ -z "$CLIENT_AWS_ACCOUNT" ] && echo "Didn't find CLIENT_AWS_ACCOUNT env var." && exit 1
[ -z "$CLIENT_AWS_REGION" ] && echo "Didn't find CLIENT_AWS_REGION env var." && exit 1
[ -z "$XILUTION_AWS_ACCOUNT" ] && echo "Didn't find XILUTION_AWS_ACCOUNT env var." && exit 1
[ -z "$XILUTION_AWS_REGION" ] && echo "Didn't find XILUTION_AWS_REGION env var." && exit 1
[ -z "$XILUTION_ENVIRONMENT" ] && echo "Didn't find XILUTION_ENVIRONMENT env var." && exit 1

echo "XILUTION_ORGANIZATION_ID: ${XILUTION_ORGANIZATION_ID}"
echo "GAZELLE_PIPELINE_ID: ${GAZELLE_PIPELINE_ID}"
echo "FOX_PIPELINE_ID: ${FOX_PIPELINE_ID}"
echo "PIPELINE_TYPE: ${PIPELINE_TYPE}"
echo "CLIENT_AWS_ACCOUNT: ${CLIENT_AWS_ACCOUNT}"
echo "CLIENT_AWS_REGION: ${CLIENT_AWS_REGION}"
echo "XILUTION_AWS_ACCOUNT: ${XILUTION_AWS_ACCOUNT}"
echo "XILUTION_AWS_REGION: ${XILUTION_AWS_REGION}"
echo "XILUTION_ENVIRONMENT: ${XILUTION_ENVIRONMENT}"

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
  "xilution_environment": "$XILUTION_ENVIRONMENT"
}
EOF
