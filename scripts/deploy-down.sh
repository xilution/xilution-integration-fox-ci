#!/bin/bash

pipelineId=${1}
stageName=${2}

stageNameLower=$(echo "${stageName}" | tr '[:upper:]' '[:lower:]')
bucket="s3://xilution-coyote-${pipelineId:0:8}-${stageNameLower}-web-content"
aws s3 rm "${bucket}" --recursive --include "*"
