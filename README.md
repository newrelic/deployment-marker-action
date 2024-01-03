[![Community Project header](https://github.com/newrelic/open-source-office/raw/master/examples/categories/images/Community_Project.png)](https://github.com/newrelic/open-source-office/blob/master/examples/categories/index.md#category-community-project)

# New Relic Application Deployment Marker

[![GitHub Marketplace version](https://img.shields.io/github/release/newrelic/deployment-marker-action.svg?label=Marketplace&logo=github)](https://github.com/marketplace/actions/new-relic-application-deployment-marker)

A GitHub Action to add New Relic deployment markers during your release pipeline.


## Inputs

| Key              | Required | Default | Description |
| ---------------- | -------- | ------- | ----------- |
| `guid`           | **yes**  | -       | The entity GUID to apply the deployment marker. |
| `apiKey`         | **yes**  | -       | Your New Relic [personal API key](https://docs.newrelic.com/docs/apis/get-started/intro-apis/types-new-relic-api-keys#personal-api-key). |
| `changelog`      | no       | -       | A summary of what changed in this deployment, visible in the Deployments page. |
| `commit`         | no       | -       | The Commit SHA for this deployment, visible in the Deployments page. |
| `description`    | no       | -       | A high-level description of this deployment, visible in the Overview page and on the Deployments page when you select an individual deployment. |
| `deeplink`       | no       | -       | A deep link to the source which triggered the deployment. |
| `deploymentType` | no       | `BASIC` | The type of deployment. Choose from BASIC, BLUE_GREEN, CANARY, OTHER, ROLLING, or SHADOW. |
| `groupId`        | no       | -       | A group ID for the deployment to link to other deployments. |
| `region`         | no       | `US`    | The region of your New Relic account. Default: `US` |
| `version`        | **yes**  | -       | Metadata to apply to the deployment marker - e.g. the latest release tag |
| `user`           | **yes**  | `github.actor` | A username to associate with the deployment, visible in the Overview page and on the Deployments page. |

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
      # When chaining steps together, the deployment id is placeed into the github environment 
      - name: View output
        run: echo "${{ env.deploymentId }}"
```
