#!/bin/sh

RED='\033[0;31m'
NO_COLOR='\033[0m'

result=$(newrelic apm deployment create --applicationId "${APPLICATION_ID}" --revision "${REVISION}" 2>&1)

exitStatus=$?

if [ $exitStatus -ne 0 ]; then
  printf "${RED}Error:${NO_COLOR} $result"
fi

exit $exitStatus
