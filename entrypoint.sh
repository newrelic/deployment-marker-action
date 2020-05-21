#!/bin/sh

result=$(newrelic apm deployment create \
  --accountId "${NEW_RELIC_ACCOUNT_ID}" \
  --applicationId "${NEW_RELIC_APPLICATION_ID}" \
  --user "${NEW_RELIC_DEPLOYMENT_USER}" \
  --revision "${NEW_RELIC_DEPLOYMENT_REVISION}" \
  --change-log "${NEW_RELIC_DEPLOYMENT_CHANGE_LOG}" \
  --description "${NEW_RELIC_DEPLOYMENT_DESCRIPTION}" \
  2>&1)

exitStatus=$?

if [ $exitStatus -ne 0 ]; then
  echo "::error:: $result"
fi

exit $exitStatus
