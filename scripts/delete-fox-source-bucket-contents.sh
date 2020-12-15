#!/bin/bash -ex

pipelineId=${FOX_PIPELINE_ID}

aws s3 rm "s3://xilution-fox-${pipelineId}-source-code" --include "*" --recursive

echo "All Done!"
