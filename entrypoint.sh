#!/bin/sh

# This script creates a New Relic Change Tracking or Deployment event.

if [ "${NEW_RELIC_COMMAND_TYPE}" = "changeTrackingCreateEvent" ]; then

  # --- Mandatory field validations based on the API schema ---
  if [ -z "${NEW_RELIC_CREATE_EVENT_CATEGORY}" ]; then
    echo "::error::'category' is a mandatory field based on the API schema."
    exit 1
  fi
  if [ -z "${NEW_RELIC_CREATE_EVENT_TYPE}" ]; then
    echo "::error::'type' is a mandatory field based on the API schema."
    exit 1
  fi
  if [ -z "${NEW_RELIC_CREATE_EVENT_ENTITY_SEARCH}" ]; then
    echo "::error::'entitySearch' is a mandatory field based on the API schema."
    exit 1
  fi

  # --- Conditional mandatory field validations ---
  if [ "${NEW_RELIC_CREATE_EVENT_CATEGORY}" = "Deployment" ]; then
    if [ -z "${NEW_RELIC_DEPLOYMENT_VERSION}" ]; then
      echo "::error::'version' is mandatory for a 'Deployment' category event."
      exit 1
    fi
  fi

  if [ "${NEW_RELIC_CREATE_EVENT_CATEGORY}" = "Feature Flag" ]; then
    if [ -z "${NEW_RELIC_CREATE_EVENT_FEATURE_FLAG_ID}" ]; then
      echo "::error::'featureFlagId' is mandatory for a 'Feature Flag' category event."
      exit 1
    fi
  fi

  # -- Conditional validations based on Category type ---
  if [ "${NEW_RELIC_CREATE_EVENT_CATEGORY}" != "Deployment" ]; then
    invalid_fields=""
        if [ -n "${NEW_RELIC_DEPLOYMENT_VERSION}" ]; then
          invalid_fields="version"
        fi
        if [ -n "${NEW_RELIC_DEPLOYMENT_CHANGE_LOG}" ]; then
          if [ -n "${invalid_fields}" ]; then
            invalid_fields="${invalid_fields}, changelog"
          else
            invalid_fields="changelog"
          fi
        fi
        if [ -n "${NEW_RELIC_DEPLOYMENT_COMMIT}" ]; then
          if [ -n "${invalid_fields}" ]; then
            invalid_fields="${invalid_fields}, commit"
          else
            invalid_fields="commit"
          fi
        fi
        if [ -n "${NEW_RELIC_DEPLOYMENT_DEEPLINK}" ]; then
          if [ -n "${invalid_fields}" ]; then
            invalid_fields="${invalid_fields}, deeplink"
          else
            invalid_fields="deeplink"
          fi
        fi
        if [ -n "${invalid_fields}" ]; then
          echo "::error::${invalid_fields} can only be used with Deployment events."
          exit 1
        fi
      fi

    if [ "${NEW_RELIC_CREATE_EVENT_CATEGORY}" != "Feature Flag" ] && [ -n "${NEW_RELIC_CREATE_EVENT_FEATURE_FLAG_ID}" ]; then
      echo "::error::'featureFlagId' is only valid for 'Feature Flag' category events."
      exit 1
    fi

  # --- Build the command string, conditionally adding optional fields ---
  command_str="newrelic changeTracking create \
    --category \"${NEW_RELIC_CREATE_EVENT_CATEGORY}\" \
    --entitySearch \"${NEW_RELIC_CREATE_EVENT_ENTITY_SEARCH}\" \
    --type \"${NEW_RELIC_CREATE_EVENT_TYPE}\""

  if [ -n "${NEW_RELIC_DEPLOYMENT_CHANGE_LOG}" ]; then
    command_str="${command_str} --changelog \"${NEW_RELIC_DEPLOYMENT_CHANGE_LOG}\""
  fi
  if [ -n "${NEW_RELIC_DEPLOYMENT_COMMIT}" ]; then
    command_str="${command_str} --commit \"${NEW_RELIC_DEPLOYMENT_COMMIT}\""
  fi
  if [ -n "${NEW_RELIC_CREATE_EVENT_CUSTOM_ATTRIBUTES}" ]; then
    command_str="${command_str} --customAttributes '${NEW_RELIC_CREATE_EVENT_CUSTOM_ATTRIBUTES}'"
  fi
  if [ -n "${NEW_RELIC_DEPLOYMENT_DEEPLINK}" ]; then
    command_str="${command_str} --deepLink \"${NEW_RELIC_DEPLOYMENT_DEEPLINK}\""
  fi
  if [ -n "${NEW_RELIC_DEPLOYMENT_DESCRIPTION}" ]; then
    command_str="${command_str} --description \"${NEW_RELIC_DEPLOYMENT_DESCRIPTION}\""
  fi
  if [ -n "${NEW_RELIC_DEPLOYMENT_GROUP_ID}" ]; then
    command_str="${command_str} --groupId \"${NEW_RELIC_DEPLOYMENT_GROUP_ID}\""
  fi
  if [ -n "${NEW_RELIC_CREATE_EVENT_SHORT_DESCRIPTION}" ]; then
    command_str="${command_str} --shortDescription \"${NEW_RELIC_CREATE_EVENT_SHORT_DESCRIPTION}\""
  fi
  if [ -n "${NEW_RELIC_CREATE_EVENT_TIMESTAMP}" ]; then
    command_str="${command_str} --timestamp \"${NEW_RELIC_CREATE_EVENT_TIMESTAMP}\""
  fi
  if [ -n "${NEW_RELIC_DEPLOYMENT_USER}" ]; then
    command_str="${command_str} --user \"${NEW_RELIC_DEPLOYMENT_USER}\""
  fi
  if [ -n "${NEW_RELIC_CREATE_EVENT_VALIDATION_FLAGS}" ]; then
    command_str="${command_str} --validationFlags \"${NEW_RELIC_CREATE_EVENT_VALIDATION_FLAGS}\""
  fi
  if [ -n "${NEW_RELIC_DEPLOYMENT_VERSION}" ]; then
    command_str="${command_str} --version \"${NEW_RELIC_DEPLOYMENT_VERSION}\""
  fi
  if [ -n "${NEW_RELIC_CREATE_EVENT_FEATURE_FLAG_ID}" ]; then
    command_str="${command_str} --featureFlagId \"${NEW_RELIC_CREATE_EVENT_FEATURE_FLAG_ID}\""
  fi

  result=$(eval "$command_str" 2>&1)

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