#!/bin/bash -e

[ -z "$CODEBUILD_SRC_DIR_SourceCode" ] && echo "Didn't find CODEBUILD_SRC_DIR_SourceCode env var." && exit 1

export XILUTION_CONFIG=$(jq -r ". | @base64" <${CODEBUILD_SRC_DIR_SourceCode}/xilution.json)

