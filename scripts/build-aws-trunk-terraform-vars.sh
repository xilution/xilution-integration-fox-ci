#!/bin/bash -e

[ -z "$XILUTION_ORGANIZATION_ID" ] && echo "Didn't find XILUTION_ORGANIZATION_ID env var." && exit 1
[ -z "$GAZELLE_PIPELINE_ID" ] && echo "Didn't find GAZELLE_PIPELINE_ID env var." && exit 1
[ -z "$FOX_PIPELINE_ID" ] && echo "Didn't find FOX_PIPELINE_ID env var." && exit 1
[ -z "$CLIENT_AWS_ACCOUNT" ] && echo "Didn't find CLIENT_AWS_ACCOUNT env var." && exit 1
[ -z "$CLIENT_AWS_REGION" ] && echo "Didn't find CLIENT_AWS_REGION env var." && exit 1
[ -z "$XILUTION_AWS_ACCOUNT" ] && echo "Didn't find XILUTION_AWS_ACCOUNT env var." && exit 1
[ -z "$XILUTION_AWS_REGION" ] && echo "Didn't find XILUTION_AWS_REGION env var." && exit 1
[ -z "$XILUTION_ENVIRONMENT" ] && echo "Didn't find XILUTION_ENVIRONMENT env var." && exit 1
[ -z "$PIPELINE_TYPE" ] && echo "Didn't find PIPELINE_TYPE env var." && exit 1

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
  "pipeline_type": "$PIPELINE_TYPE"
}
EOF
