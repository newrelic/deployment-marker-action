#!/bin/sh

if [ "${NEW_RELIC_COMMAND_TYPE}" = "changeTrackingCreateEvent" ]; then

    # Validation for createEvent API when category is set to Deployment
    if [ "${NEW_RELIC_CREATE_EVENT_CATEGORY}" = "Deployment" ]; then
      if [ -z "${NEW_RELIC_DEPLOYMENT_VERSION}" ]; then
        echo "::error::'version' is mandatory for createEvent API when category is set to 'Deployment'."
        exit 1
      fi
    fi

    # Validation for createEvent API when category is set to Feature Flag
    if [ "${NEW_RELIC_CREATE_EVENT_CATEGORY}" = "Feature Flag" ]; then
      if [ -z "${NEW_RELIC_CREATE_EVENT_FEATURE_FLAG_ID}" ]; then
        echo "::error::'featureFlagId' is mandatory for createEvent API when category is set to 'Feature Flag'."
        exit 1
      fi
    fi

  # Execute New Relic changeTrackingCreateEvent command
  result=$(newrelic changeTracking create \
    --category "${NEW_RELIC_CREATE_EVENT_CATEGORY}" \
    --changelog "${NEW_RELIC_DEPLOYMENT_CHANGE_LOG}" \
    --commit "${NEW_RELIC_DEPLOYMENT_COMMIT}" \
    --customAttributes "${NEW_RELIC_CREATE_EVENT_CUSTOM_ATTRIBUTES}" \
    --deepLink "${NEW_RELIC_DEPLOYMENT_DEEPLINK}" \
    --description "${NEW_RELIC_DEPLOYMENT_DESCRIPTION}" \
    --entitySearch "${NEW_RELIC_CREATE_EVENT_ENTITY_SEARCH}" \
    --featureFlagId "${NEW_RELIC_CREATE_EVENT_FEATURE_FLAG_ID}" \
    --groupId "${NEW_RELIC_DEPLOYMENT_GROUP_ID}" \
    --shortDescription "${NEW_RELIC_CREATE_EVENT_SHORT_DESCRIPTION}" \
    --timestamp "${NEW_RELIC_CREATE_EVENT_TIMESTAMP}" \
    --type "${NEW_RELIC_CREATE_EVENT_TYPE}" \
    --user "${NEW_RELIC_DEPLOYMENT_USER}" \
    --validationFlags "${NEW_RELIC_CREATE_EVENT_VALIDATION_FLAGS}" \
    --version "${NEW_RELIC_DEPLOYMENT_VERSION}" \
    2>&1)

else
  # Validation for createDeployment API
    if [ -z "${NEW_RELIC_DEPLOYMENT_VERSION}" ]; then
      echo "::error::'version' is mandatory for createDeployment API."
      exit 1
    fi

  # Execute New Relic entity deployment command
  result=$(newrelic entity deployment create \
    --changelog "${NEW_RELIC_DEPLOYMENT_CHANGE_LOG}" \
    --commit "${NEW_RELIC_DEPLOYMENT_COMMIT}" \
    --deepLink "${NEW_RELIC_DEPLOYMENT_DEEPLINK}" \
    --deploymentType "${NEW_RELIC_DEPLOYMENT_TYPE}" \
    --description "${NEW_RELIC_DEPLOYMENT_DESCRIPTION}" \
    --guid "${NEW_RELIC_DEPLOYMENT_ENTITY_GUID}" \
    --groupId "${NEW_RELIC_DEPLOYMENT_GROUP_ID}" \
    --user "${NEW_RELIC_DEPLOYMENT_USER}" \
    --version "${NEW_RELIC_DEPLOYMENT_VERSION}" \
    2>&1)
fi

exitStatus=$?
echo "$result"

if [ $exitStatus -ne 0 ]; then
  echo "::error:: $result"
fi

if [ "${NEW_RELIC_COMMAND_TYPE}" != "changeTrackingCreateEvent" ]; then
  deploymentId=$(echo "$result" | grep deploymentId | cut -d '"' -f4- | cut -d '"' -f1)
  echo "deploymentId=$deploymentId" >> "${GITHUB_OUTPUT}"
fi

exit $exitStatus