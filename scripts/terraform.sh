#!/bin/bash -e

[ -z "$1" ] && echo "The first argument should be the pipeline phase (trunk or stage)." && exit 1
[ -z "$2" ] && echo "The second argument should be the pipeline direction (up or down)." && exit 1
[ -z "$3" ] && echo "The third argument should be the Terraform module path." && exit 1
[ -z "$4" ] && echo "The fourth argument should be the Terraform state file name." && exit 1
[ -z "$5" ] && echo "The fifth argument should be the Terraform provider (aws)." && exit 1
[ -z "$6" ] && echo "The sixth argument should be the Xilution product category." && exit 1
[ -z "$7" ] && echo "The seventh argument should be the Xilution product code." && exit 1
[ -z "$PIPELINE_ID" ] && echo "Didn't find PIPELINE_ID env var." && exit 1
[ -z "$CLIENT_AWS_ACCOUNT" ] && echo "Didn't find CLIENT_AWS_ACCOUNT env var." && exit 1

phase=${1}
direction=${2}
tfPath=${3}
tfStateFileName=${4}
tfProvider=${5}
productCategory=${6}
productName=${7}

echo "phase: ${phase}"
echo "direction: ${direction}"
echo "tfPath: ${tfPath}"
echo "tfStateFileName: ${tfStateFileName}"
echo "tfProvider: ${tfProvider}"
echo "productCategory: ${productCategory}"
echo "productName: ${productName}"

if [[ ! -d ${tfPath} ]]; then
  echo "Unable to find Terraform path: ${tfPath}. Nothing to do. Exiting now without raising an error."
  exit 0
fi

currentDir=$(pwd)
cd ${tfPath}

if [[ "${tfProvider}" == "aws" ]]; then
  if [[ "${phase}" == "trunk" ]]; then
    terraform init -no-color \
      -backend-config="key=xilution-${productCategory}-${productName}/${PIPELINE_ID}/${tfStateFileName}" \
      -backend-config="bucket=xilution-terraform-backend-state-bucket-${CLIENT_AWS_ACCOUNT}" \
      -backend-config="dynamodb_table=xilution-terraform-backend-lock-table"
    bash ./scripts/build-aws-trunk-terraform-vars.sh
  elif [[ "${phase}" == "stage" ]]; then
    [ -z "$STAGE_NAME" ] && echo "Didn't find STAGE_NAME env var." && exit 1
    terraform init -no-color \
      -backend-config="key=xilution-${productCategory}-${productName}/${PIPELINE_ID}/${STAGE_NAME}/${tfStateFileName}" \
      -backend-config="bucket=xilution-terraform-backend-state-bucket-${CLIENT_AWS_ACCOUNT}" \
      -backend-config="dynamodb_table=xilution-terraform-backend-lock-table"
    bash ./scripts/build-aws-stage-terraform-vars.sh
  else
    echo "Unsupported phase: ${phase}."
    exit 1
  fi
else
  echo "Unsupported tfProvider: ${tfProvider}."
  exit 1
fi

if [[ "${direction}" == "up" ]]; then
  terraform plan -no-color -var-file=tfvars.json -out=./terraform-plan.txt
  terraform apply -auto-approve -no-color ./terraform-plan.txt
elif [[ "${direction}" == "down" ]]; then
  terraform destroy -auto-approve -no-color
else
  echo "Unsupported direction: ${direction}."
  exit 1
fi

cd ${currentDir}

echo "All Done!"
