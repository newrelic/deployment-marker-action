[![Community Project header](https://github.com/newrelic/open-source-office/raw/master/examples/categories/images/Community_Project.png)](https://github.com/newrelic/open-source-office/blob/master/examples/categories/index.md#category-community-project)

# New Relic Application Deployment Marker

[![GitHub Marketplace version](https://img.shields.io/github/release/newrelic/deployment-marker-action.svg?label=Marketplace&logo=github)](https://github.com/marketplace/actions/new-relic-application-deployment-marker)

A GitHub Action to add New Relic deployment markers during your release pipeline.

The Action supports two primary API mutations for submitting events:

#### changeTrackingCreateDeployment (Legacy):
This mutation is designed specifically for submitting traditional deployment events. It represents the older method for sending deployment-focused information to New Relic.

#### changeTrackingCreateEvent (RECOMMENDED):
This is our latest and most flexible API mutation, offering extensive customization capabilities. It allows you to comprehensively track any type of change event, which includes, but is not limited to, deployments, along with custom attributes, feature flag rollouts, and various custom change events.
It is important to note this will create a `ChangeTrackingEvent` event instead of a `Deployment` event and is a paid feature, billed per event rather than by data volume (per GB).

The `command_type` must be set to `change-tracking` to enable this functionality. Please refer below example for more details and its usage.
For more details on change tracking event mutation, please refer to our [docs](https://docs.newrelic.com/docs/change-tracking/change-tracking-events/#change-tracking-event-mutation)

## Inputs

| Key                    | Required | Default        | Description                                                                                                                                                                                                           |
|------------------------|----------|----------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `guid`                 | yes      | -              | The entity GUID to apply the deployment marker.                                                                                                                                                                       |
| `apiKey`               | yes      | -              | Your New Relic [personal API key](https://docs.newrelic.com/docs/apis/get-started/intro-apis/types-new-relic-api-keys#personal-api-key).                                                                              |
| `changelog`            | no       | -              | A summary of what changed in this deployment, visible in the Deployments page.                                                                                                                                        |
| `commit`               | no       | -              | The Commit SHA for this deployment, visible in the Deployments page.                                                                                                                                                  |
| `description`          | no       | -              | A high-level description of this deployment, visible in the Overview page and on the Deployments page when you select an individual deployment.                                                                       |
| `deeplink`             | no       | -              | A deep link to the source which triggered the deployment.                                                                                                                                                             |
| `deploymenttype`       | no       | `BASIC`        | The type of deployment. Choose from BASIC, BLUE_GREEN, CANARY, OTHER, ROLLING, or SHADOW.                                                                                                                             |
| `groupid`              | no       | -              | A group ID for the deployment to link to other deployments.                                                                                                                                                           |
| `region`               | no       | `US`           | The region of your New Relic account. Default: `US`                                                                                                                                                                   |
| `version`              | yes      | -              | Metadata to apply to the deployment marker - e.g. the latest release tag                                                                                                                                              |
| `user`                 | yes      | `github.actor` | A username to associate with the deployment, visible in the Overview page and on the Deployments page.                                                                                                                |
| `command_type`         | no       | -              | This field lets you track any change event. To use this new API mutation, simply set it to "change-tracking".                                                                                                         |
| `category`             | yes      | -              | The category of the change event. For a list of supported categories, [view our docs](https://docs.newrelic.com/docs/change-tracking/change-tracking-events/#supported-types).                                        |
| `type`                 | yes      | -              | The type of the change event. For a list of supported types, [view our docs](https://docs.newrelic.com/docs/change-tracking/change-tracking-events/#supported-types)                                                  |
| `featureFlagId`        | yes      | -              | The ID of the feature flag associated with the change event. This is required if the command_type is "change-tracking" and the category is "FEATURE_FLAG".                                                            |
| `customAttributes`     | no       | -              | Represents key-value pairs of custom attributes in JavaScript object format. Attribute values can be of type string, boolean, or number.                                                                              |
| `customAttributesFile` | no       | -              | Path to a file containing custom attributes in JavaScript object format. This field is mutually exclusive with `customAttributes`. Either `customAttributes` or `customAttributesFile` can be provided, but not both. |
| `entitySearch`         | yes      | -              | Specify the entity to associate with the change tracking event via query.                                                                                                                                             |
| `shortDescription`     | no       | -              | This field allows you to add your own context to help you quickly identify the change events sent to our system.                                                                                                      |
| `timestamp`            | no       | -              | The start time of the change tracking event as the number of milliseconds since the Unix epoch. Defaults to now.                                                                                                      |
| `validationFlags`      | no       | -              | Validation flags for the change event (e.g., "`[ALLOW_CUSTOM_CATEGORY_OR_TYPE]`, `[FAIL_ON_FIELD_LENGTH]`, `[FAIL_ON_REST_API_FAILURES]`"). Only applicable if command_type is "change-tracking".                     |

## Example usage

### GitHub secrets

[Github secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets#about-encrypted-secrets) assumed to be set:
* `NEW_RELIC_API_KEY` - Personal API key
* `NEW_RELIC_DEPLOYMENT_ENTITY_GUID` - New Relic Entity GUID to create the marker on

>*There are a number of [default GitHub environment variables](https://docs.github.com/en/actions/learn-github-actions/variables#default-environment-variables) that are used in these examples as well.*
### Minimum required fields

```yaml
name: Change Tracking Marker
on:
  - release
      types: [published]

jobs:
  newrelic:
    runs-on: ubuntu-latest
    name: New Relic
    steps:
      # This step builds a var with the release tag value to use later
      - name: Set Release Version from Tag
        run: echo "RELEASE_VERSION=${{ github.ref_name }}" >> $GITHUB_ENV
      # This step creates a new Change Tracking Marker
      - name: New Relic Application Deployment Marker
        uses: newrelic/deployment-marker-action@v2.2.0
        with:
          apiKey: ${{ secrets.NEW_RELIC_API_KEY }}
          region: "US"
          guid: ${{ secrets.NEW_RELIC_DEPLOYMENT_ENTITY_GUID }}
          version: "${{ env.RELEASE_VERSION }}"
          user: "${{ github.actor }}"
```

### All input fields

>*In addition to `NEW_RELIC_API_KEY`, this example shows how to target multiple items by storing multiple secrets like "`NEW_RELIC_DEPLOYMENT_ENTITY_GUID_<ID>`", where `<ID>` is the unique identifier for the target item.*

```
NEW_RELIC_DEPLOYMENT_ENTITY_GUID_App123
NEW_RELIC_DEPLOYMENT_ENTITY_GUID_App456
NEW_RELIC_DEPLOYMENT_ENTITY_GUID_App789
```

```yaml
name: Change Tracking Marker
on:
  workflow_dispatch:
  release:
    types: [published]

jobs:
  newrelic:
    runs-on: ubuntu-latest
    name: New Relic
    steps:
      # This step builds a var with the release tag value to use later
      - name: Set Release Version from Tag
        run: echo "RELEASE_VERSION=${{ github.ref_name }}" >> $GITHUB_ENV
      # This step creates a new Change Tracking Marker for App123
      - name: App123 Marker
        uses: newrelic/deployment-marker-action@v2.2.0
        with:
          apiKey: ${{ secrets.NEW_RELIC_API_KEY }}
          region: "US"
          guid: ${{ secrets.NEW_RELIC_DEPLOYMENT_ENTITY_GUID_App123 }}
          version: "${{ env.RELEASE_VERSION }}"
          changelog: "https://github.com/${{ github.repository }}/blob/master/CHANGELOG.md"
          commit: "${{ github.sha }}"
          description: "Automated Release via Github Actions"
          deploymenttype: "ROLLING"
          groupId: "Workshop App Release: ${{ github.ref_name }}"
          user: "${{ github.actor }}"
      # This step creates a new Change Tracking Marker for App
      - name: App456 Marker
        uses: newrelic/deployment-marker-action@v2.2.0
        with:
          apiKey: ${{ secrets.NEW_RELIC_API_KEY }}
          region: "US"
          guid: ${{ secrets.NEW_RELIC_DEPLOYMENT_ENTITY_GUID_App456 }}
          version: "${{ env.RELEASE_VERSION }}"
          changelog: "https://github.com/${{ github.repository }}/blob/master/CHANGELOG.md"
          commit: "${{ github.sha }}"
          description: "Automated Release via Github Actions"
          deploymenttype: "ROLLING"
          groupId: "Workshop App Release: ${{ github.ref_name }}"
          user: "${{ github.actor }}"
      # This step creates a new Change Tracking Marker for App789
      - name: App789 Marker
        uses: newrelic/deployment-marker-action@v2.2.0
        with:
          apiKey: ${{ secrets.NEW_RELIC_API_KEY }}
          region: "US"
          guid: ${{ secrets.NEW_RELIC_DEPLOYMENT_ENTITY_GUID_App789 }}
          version: "${{ env.RELEASE_VERSION }}"
          changelog: "https://github.com/${{ github.repository }}/blob/master/CHANGELOG.md"
          commit: "${{ github.sha }}"
          description: "Automated Release via Github Actions"
          deploymenttype: "ROLLING"
          groupId: "Workshop App Release: ${{ github.ref_name }}"
          user: "${{ github.actor }}"
      # When chaining steps together, the deployment id is placed into the github environment 
      - name: View output
        run: echo "${{ env.deploymentId }}"
```

### ChangeTracking Event Example (RECOMMENDED)

The below example outlines the usage of the `changeTrackingCreateEvent` capability, will allow deployment events to be reported as rich Change Tracking events, providing more comprehensive metadata and better integration with New Relic's observability platform.
For more details on change tracking event mutation, please refer to our [docs](https://docs.newrelic.com/docs/change-tracking/change-tracking-events/#change-tracking-event-mutation)

```yaml
jobs:
  newrelic:
    runs-on: ubuntu-latest
    name: New Relic ChangeTracking Event 
    steps:
      # This step builds a var with the release tag value to use later
      - name: Set Release Version from Tag
        run: echo "RELEASE_VERSION=${{ github.ref_name }}" >> $GITHUB_ENV
      - name: Test change event deployment marker
        uses: newrelic/deployment-marker-action@v2.2.0
        with:
          apiKey: ${{ secrets.NEW_RELIC_API_KEY }}
          command_type: "change-tracking"
          entitySearch: "id='entity-guid'"
          guid: ${{ secrets.NEW_RELIC_DEPLOYMENT_ENTITY_GUID }}
          version: "${{ env.RELEASE_VERSION }}"
          category: 'FEATURE_FLAG'
          type: 'basic'
          changelog: "https://github.com/${{ github.repository }}/blob/master/CHANGELOG.md"
          commit: "${{ github.sha }}"
          deepLink: "https://example.com/deployment"
          description: "Automated Release via Github Actions"
          featureFlagId: "feature-flag-1"
          user: "${{ github.actor }}"
          groupId: "deploy-group-1"
          shortDescription: "Pre-Prod deploy"
          timestamp: "${{ github.event.release.published_at }}"
          validationFlags: '[ALLOW_CUSTOM_CATEGORY_OR_TYPE]'
          customAttributes: '{cloud_vendor : "vendor_name", region : "us-east-1", environment : "staging"}'
```