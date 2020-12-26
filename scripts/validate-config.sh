#!/bin/bash -e

productCode=${1}
sourceDir=${CODEBUILD_SRC_DIR_SourceCode}
currentDir=$(pwd)
cd "${sourceDir}" || false
event=$(jq "{ \"config\": ., \"productCode\": \"${productCode}\" } | @base64" <./xilution.json)
cd "${currentDir}" || false

aws lambda invoke \
  --function-name xilution-pipeline-config-validation-lambda \
  --invocation-type RequestResponse \
  --log-type Tail \
  --payload ${event} \
  ./response.json

error=$(jq ".error" <./response.json)

if [[ "${error}" != "null" ]]; then
  details=$(jq ".error.details" <./response.json)
  echo "Invalid xilution.json pipeline. Please correct the following errors."
  echo ${details}
  echo "Exiting now."
  exit 1
else
  echo "Congratulations! xilution.json is valid."
fi

rm -rf response.json
