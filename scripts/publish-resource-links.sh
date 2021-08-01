#!/bin/bash -e

[ -z "$1" ] && echo "The first argument should be the Terraform module path." && exit 1

tfPath=${1}

if [[ ! -d ${tfPath} ]]; then
  echo "Unable to find Terraform path: ${tfPath}. Nothing to do. Exiting now without raising an error."
  exit 0
fi

currentDir=$(pwd)
cd ${tfPath}

terraform show -json -no-color > ./terraform-output.json

unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN
publishResourceLinksQueueUrl="https://sqs.us-east-1.amazonaws.com/952573012699/xilution-publish-resource-links-request-queue"
aws sqs send-message --queue-url ${publishResourceLinksQueueUrl} --message-body file://./terraform-output.json

cd ${currentDir}
