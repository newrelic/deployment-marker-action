#!/bin/sh

result=$(newrelic apm deployment create --applicationId "${APPLICATION_ID}" --revision "${REVISION}" --accountId "${NEW_RELIC_ACCOUNT_ID}" --user "${NEW_RELIC_DEPLOYMENT_USER}" 2>&1)

exitStatus=$?

if [ $exitStatus -ne 0 ]; then
  echo "::error:: $result"
fi

exit $exitStatus
