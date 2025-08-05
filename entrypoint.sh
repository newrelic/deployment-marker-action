#!/bin/sh

if [ "${NEW_RELIC_COMMAND_TYPE}" = "createEvent" ]; then

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
    --entitySearch "${NEW_RELIC_CREATE_EVENT_ENTITY_SEARCH}" \
    --category "${NEW_RELIC_CREATE_EVENT_CATEGORY}" \
    --type "${NEW_RELIC_CREATE_EVENT_TYPE}" \
    --featureFlagId "${NEW_RELIC_CREATE_EVENT_FEATURE_FLAG_ID}" \
    --validationFlags "${NEW_RELIC_CREATE_EVENT_VALIDATION_FLAGS}" \
    --version "${NEW_RELIC_DEPLOYMENT_VERSION}" \
    --changelog "${NEW_RELIC_DEPLOYMENT_CHANGE_LOG}" \
    --commit "${NEW_RELIC_DEPLOYMENT_COMMIT}" \
    --deepLink "${NEW_RELIC_DEPLOYMENT_DEEPLINK}" \
    --description "${NEW_RELIC_DEPLOYMENT_DESCRIPTION}" \
    --user "${NEW_RELIC_DEPLOYMENT_USER}" \
    --customAttributes "${NEW_RELIC_CREATE_EVENT_CUSTOM_ATTRIBUTES}" \
    2>&1)

else
  # Validation for createDeployment API
    if [ -z "${NEW_RELIC_DEPLOYMENT_VERSION}" ]; then
      echo "::error::'version' is mandatory for createDeployment API."
      exit 1
    fi

  # Execute New Relic entity deployment command
  result=$(newrelic entity deployment create \
    --guid "${NEW_RELIC_DEPLOYMENT_ENTITY_GUID}" \
    --user "${NEW_RELIC_DEPLOYMENT_USER}" \
    --version "${NEW_RELIC_DEPLOYMENT_VERSION}" \
    --changelog "${NEW_RELIC_DEPLOYMENT_CHANGE_LOG}" \
    --commit "${NEW_RELIC_DEPLOYMENT_COMMIT}" \
    --description "${NEW_RELIC_DEPLOYMENT_DESCRIPTION}" \
    --deepLink "${NEW_RELIC_DEPLOYMENT_DEEPLINK}" \
    --deploymentType "${NEW_RELIC_DEPLOYMENT_TYPE}" \
    --groupId "${NEW_RELIC_DEPLOYMENT_GROUP_ID}" \
    2>&1)
fi

exitStatus=$?
echo "$result"

if [ $exitStatus -ne 0 ]; then
  echo "::error:: $result"
fi

if [ "${NEW_RELIC_COMMAND_TYPE}" != "createEvent" ]; then
  deploymentId=$(echo "$result" | grep deploymentId | cut -d '"' -f4- | cut -d '"' -f1)
  echo "deploymentId=$deploymentId" >> "${GITHUB_OUTPUT}"
fi

exit $exitStatus