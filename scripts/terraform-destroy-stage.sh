#!/bin/bash -ex

pipelineId=${FOX_PIPELINE_ID}
stageName=${STAGE_NAME}
sourceDir=${CODEBUILD_SRC_DIR_SourceCode}
clientAwsAccount=${CLIENT_AWS_ACCOUNT}

stageNameLower=$(echo "${stageName}" | tr '[:upper:]' '[:lower:]')
apiLambdaStackName="xilution-fox-${pipelineId:0:8}-stage-${stageNameLower}-api-lambda-stack"
apiIdQuery=".Stacks[0].Outputs | map(select(.ExportName == \"${apiLambdaStackName}-api\")) | .[] .OutputValue"
apiId=$(aws cloudformation describe-stacks --stack-name "${apiLambdaStackName}" | jq -r "${apiIdQuery}")
echo apiId=${apiId}

integration=".Stacks[0].Outputs | map(select(.ExportName == \"${apiLambdaStackName}-integration\")) | .[] .OutputValue"
integration=$(aws cloudformation describe-stacks --stack-name "${apiLambdaStackName}" | jq -r "${integration}")
target="integrations/${integration}"
echo target=${target}

currentDir=$(pwd)
cd "${sourceDir}" || false
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

terraform destroy \
  -var="client_aws_account=${CLIENT_AWS_ACCOUNT}" \
  -var="api_id=${apiId}" \
  -var="route_keys=[${routeKeys}]" \
  -var="target=${target}" \
  -auto-approve \
  ./terraform/stage

echo "All Done!"
