#!/bin/bash

wait_for_site_to_be_ready() {

  siteUrl=${1}
  count=0
  sleepSeconds=5
  maxAttempts=60

  while [[ $(curl -s -o /dev/null -w '%{http_code}' "${siteUrl}") != "200" && "${count}" < "${maxAttempts}" ]]; do
    sleep ${sleepSeconds}
    count=$((count + 1))
  done

  if [[ "$count" == "${maxAttempts}" ]]; then
    aws codebuild stop-build --id "${CODEBUILD_BUILD_ID}"
  fi
}

execute_commands() {

  commands=${1}

  for command in ${commands}; do
    echo "${command}" | base64 --decode | bash
  done
}
