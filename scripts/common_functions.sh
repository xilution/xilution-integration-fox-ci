#!/bin/bash -ex

create_or_update_cloudformation_stack() {

  pipelineId=${1}
  stackName=${2}
  parameters=${3}
  templateBody=${4}

  echo "pipelineId = ${pipelineId}"
  echo "stackName = ${stackName}"
  echo "parameters = ${parameters}"
  echo "templateBody = ${templateBody}"

  stackStatusQuery=".StackSummaries[] | select(.StackName == \"${stackName}\" and .StackStatus != \"DELETE_COMPLETE\") | .StackStatus"
  stackStatus=$(aws cloudformation list-stacks --no-paginate | jq -r "${stackStatusQuery}")

  echo "stackStatus = ${stackStatus}"

  if [[ -z "${stackStatus}" ]]; then
    echo "Didn't find an active stack, creating now..."
    aws cloudformation create-stack \
      --stack-name "${stackName}" \
      --parameters "${parameters}" \
      --capabilities CAPABILITY_NAMED_IAM \
      --template-body "${templateBody}"
    echo "Waiting for stack create to complete."
    aws cloudformation wait stack-create-complete \
      --stack-name "${stackName}"
    echo "Stack create is complete."
  else
    echo "Stack found. Checking for changes..."
    uuid=$(uuidgen)
    changeSetName="xilution-fox-${pipelineId:0:8}-${uuid:0:8}-change-set"
    aws cloudformation create-change-set \
      --stack-name "${stackName}" \
      --change-set-name "${changeSetName}" \
      --parameters "${parameters}" \
      --template-body "${templateBody}"
    echo "Waiting for create stack change set to complete."
    aws cloudformation wait change-set-create-complete \
      --stack-name "${stackName}" \
      --change-set-name "${changeSetName}"
    echo "Create stack change set is complete."
    changeSet=$(aws cloudformation describe-change-set --stack-name "${stackName}" --change-set-name "${changeSetName}")
    changesQuery=".Changes[]"
    changes=$(echo "${changeSet}" | jq -r "${changesQuery}")
    if [[ -n "${changes}" ]]; then
      echo "The following changes were found."
      echo "${changes}"
      echo "Applying them now..."
      aws cloudformation execute-change-set \
        --stack-name "${stackName}" \
        --change-set-name "${changeSetName}"
      echo "Waiting for stack changes to be applied."
      aws cloudformation wait stack-update-complete \
        --stack-name "${stackName}"
      echo "Applying stack changes is complete"
    else
      echo "No changes found. Nothing to do."
    fi
  fi
}

delete_cloudformation_stack() {

  stackName=${1}

  echo "Deleting stack ${stackName}"
  aws cloudformation delete-stack \
    --stack-name "${stackName}"
  echo "Waiting for stack delete to complete."
  aws cloudformation wait stack-delete-complete \
    --stack-name "${stackName}"
  echo "Stack delete is complete."
}

execute_commands() {

  commands=${1}

  for command in ${commands}; do
    echo "${command}" | base64 --decode | bash
  done
}
