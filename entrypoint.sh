#!/bin/sh

result=$(newrelic entity deployment create \
  --guid "${NEW_RELIC_DEPLOYMENT_ENTITY_GUID}" \
  --user "${NEW_RELIC_DEPLOYMENT_USER}" \
  --version "${NEW_RELIC_DEPLOYMENT_VERSION}" \
  --changelog "${NEW_RELIC_DEPLOYMENT_CHANGE_LOG}" \
  --description "${NEW_RELIC_DEPLOYMENT_DESCRIPTION}" \
  --deepLink "${NEW_RELIC_DEPLOYMENT_DEEPLINK}" \
  --deploymentType "${NEW_RELIC_DEPLOYMENT_TYPE}" \
  --groupId "${NEW_RELIC_DEPLOYMENT_GROUP_ID}" \
  2>&1)

exitStatus=$?

if [ $exitStatus -ne 0 ]; then
  echo "::error:: $result"
fi

exit $exitStatus
