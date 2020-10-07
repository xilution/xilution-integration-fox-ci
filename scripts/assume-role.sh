#!/bin/bash

awsAccountId=${1}
awsRole=${2}

aws sts assume-role \
  --role-arn arn:aws:iam::"${awsAccountId}":role/"${awsRole}" \
  --role-session-name xilution-client-session >./aws-creds.json

awsAccessKeyId=$(cat <./aws-creds.json | jq -r ".Credentials.AccessKeyId")
export AWS_ACCESS_KEY_ID=${awsAccessKeyId}

awsSecretAccessKey=$(cat <./aws-creds.json | jq -r ".Credentials.SecretAccessKey")
export AWS_SECRET_ACCESS_KEY=${awsSecretAccessKey}

awsSessionToken=$(cat <./aws-creds.json | jq -r ".Credentials.SessionToken")
export AWS_SESSION_TOKEN=${awsSessionToken}
