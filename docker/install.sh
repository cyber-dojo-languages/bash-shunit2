#!/bin/bash -Eeu

# Appends one test framework to the test_frameworks list the base image
# wrote in /versions.json, keeping any entry an earlier image added. Stops
# the build if the list is not found, rather than record nothing. Short grep
# flags because busybox grep has no long ones.
add_test_framework()
{
  local -r name="${1}"
  local -r version="${2}"
  local -r entry="{\"name\": \"${name}\", \"version\": \"${version}\"}"
  if grep -q '"test_frameworks": \[\]' /versions.json; then
    sed -i "s|\"test_frameworks\": \[\]|\"test_frameworks\": [${entry}]|" /versions.json
  else
    sed -i "/\"test_frameworks\": \[/s|}\]|}, ${entry}]|" /versions.json
  fi
  if ! grep -q -F "${entry}" /versions.json; then
    echo "Could not add ${name} to /versions.json" >&2
    cat /versions.json >&2
    exit 1
  fi
}

apk add curl

# shunit2 comes from its master branch, which is its newest code. Its last
# tagged release, 2.1.8, counts a failing assert twice and reports the test
# function's non-zero return as an error, so a kata with one failure would
# read FAILED (failures=2) under it.
curl --silent --fail --location --output /usr/bin/shunit2 \
  https://raw.githubusercontent.com/kward/shunit2/refs/heads/master/shunit2
apk del curl

# shunit2 states its own version in the script, so that is what is recorded.
readonly SHUNIT2_VERSION=$(sed -n "s/^SHUNIT_VERSION='\(.*\)'$/\1/p" /usr/bin/shunit2)

if [ -z "${SHUNIT2_VERSION}" ]; then
  echo 'Could not read SHUNIT_VERSION from /usr/bin/shunit2' >&2
  exit 1
fi

add_test_framework shunit2 "${SHUNIT2_VERSION}"
cat /versions.json
