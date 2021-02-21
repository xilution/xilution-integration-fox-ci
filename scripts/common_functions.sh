#!/bin/bash -e

wait_for_site_to_be_ready() {

  siteUrl=${1}
  count=0
  sleepSeconds=5
  maxAttempts=60

  echo "Checking the status of url: ${siteUrl}"

  while [[ $(curl -s -o /dev/null -w '%{http_code}' "${siteUrl}") != "200" && "${count}" -lt "${maxAttempts}" ]]; do
    sleep ${sleepSeconds}
    count=$((count + 1))
    echo "Not ready yet."
  done

  if [[ "${count}" == "${maxAttempts}" ]]; then
    echo "The site was never ready. Stopping the build and exiting now."
    aws codebuild stop-build --id "${CODEBUILD_BUILD_ID}"
    exit 1
  fi
}

execute_commands() {

  commands=${1}

  for command in ${commands}; do
    echo "${command}" | base64 --decode | bash
  done
}
