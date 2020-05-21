#!/bin/sh

RED='\033[0;31m'
NO_COLOR='\033[0m'

result=$(newrelic apm deployment create --applicationId "${APPLICATION_ID}" --revision "${REVISION}" --accountId "${NEW_RELIC_ACCOUNT_ID}" --user "${NEW_RELIC_DEPLOYMENT_USER}" 2>&1)

exitStatus=$?

if [ $exitStatus -ne 0 ]; then
  printf "${RED}Error:${NO_COLOR} $result"
fi

exit $exitStatus
