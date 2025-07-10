#!/bin/sh

if [ "${INPUT_COMMAND_TYPE}" = "change-tracking" ]; then
  # Set custom attributes option and value
  if [ -n "${NEW_RELIC_CHANGE_EVENT_CUSTOM_ATTRIBUTES}" ]; then
    customAttributesOption="--customAttributes"
    customAttributesValue="${NEW_RELIC_CHANGE_EVENT_CUSTOM_ATTRIBUTES}"
  elif [ -n "${NEW_RELIC_CHANGE_EVENT_CUSTOM_ATTRIBUTES_FILE}" ]; then
    customAttributesOption="--customAttributesFile"
    customAttributesValue="${NEW_RELIC_CHANGE_EVENT_CUSTOM_ATTRIBUTES_FILE}"
  else
    customAttributesOption=""
    customAttributesValue=""
  fi

  # Execute New Relic changeTracking command
  result=$(newrelic changeTracking create \
    --entitySearch "${NEW_RELIC_CHANGE_EVENT_ENTITY_SEARCH}" \
    --category "${NEW_RELIC_CHANGE_EVENT_CATEGORY}" \
    --type "${NEW_RELIC_CHANGE_EVENT_TYPE}" \
    --featureFlagId "${NEW_RELIC_CHANGE_EVENT_FEATURE_FLAG_ID}" \
    --validationFlags "${NEW_RELIC_CHANGE_EVENT_VALIDATION_FLAGS}" \
    --version "${NEW_RELIC_DEPLOYMENT_VERSION}" \
    --changelog "${NEW_RELIC_DEPLOYMENT_CHANGE_LOG}" \
    --commit "${NEW_RELIC_DEPLOYMENT_COMMIT}" \
    --deepLink "${NEW_RELIC_DEPLOYMENT_DEEPLINK}" \
    --description "${NEW_RELIC_DEPLOYMENT_DESCRIPTION}" \
    --user "${NEW_RELIC_DEPLOYMENT_USER}" \
    ${customAttributesOption:+${customAttributesOption} "${customAttributesValue}"} \
    2>&1)
else
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

if [ "${INPUT_COMMAND_TYPE}" != "change-tracking" ]; then
  deploymentId=$(echo "$result" | grep deploymentId | cut -d '"' -f4- | cut -d '"' -f1)
  echo "deploymentId=$deploymentId" >> "${GITHUB_OUTPUT}"
fi

exit $exitStatus