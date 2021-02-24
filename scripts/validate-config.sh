#!/bin/bash -e

[ -z "$PRODUCT_CODE" ] && echo "Didn't find PRODUCT_CODE env var." && exit 1
[ -z "$XILUTION_CONFIG" ] && echo "Didn't find XILUTION_CONFIG env var." && exit 1

productCode=${PRODUCT_CODE}
event=$(echo "${XILUTION_CONFIG}" | base64 --decode | jq "{ \"config\": ., \"productCode\": \"${productCode}\" } | @base64")

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
