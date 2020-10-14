#!/bin/bash -ex

pipelineId=${FOX_PIPELINE_ID}

aws s3 rm "s3://xilution-fox-${pipelineId:0:8}-source-code" --include "*" --recursive
