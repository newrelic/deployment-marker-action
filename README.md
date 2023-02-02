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
| `description`    | no       | -       | A high-level description of this deployment, visible in the Overview page and on the Deployments page when you select an individual deployment. |
| `deeplink`       | no       | -       | A deep link to the source which triggered the deployment. |
| `deploymentType` | no       | `BASIC` | The type of deployment. Choose from BASIC, BLUE_GREEN, CANARY, OTHER, ROLLING, or SHADOW. |
| `groupId`        | no       | -       | A group ID for the deployment to link to other deployments. |
| `region`         | no       | `US`    | The region of your New Relic account. Default: `US` |
| `version`        | **yes**  | -       | Metadata to apply to the deployment marker - e.g. the latest release tag |
| `user`           | **yes**  | `github.actor` | A username to associate with the deployment, visible in the Overview page and on the Deployments page. |

## Example usage

#### Use Release Tag for Revision

The following example could be added as a job to your existing workflow that
creates a New Relic deployment marker with the revision being the release Tag.

Github secrets assumed to be set:
* `NEW_RELIC_API_KEY` - Personal API key
* `NEW_RELIC_DEPLOYMENT_ENTITY_GUID` - New Relic Entity GUID to create the marker on

```yaml
name: Release

on:
  - release

jobs:
  newrelic:
    runs-on: ubuntu-latest
    name: New Relic
    steps:
      - name: Set Release Version from Tag
        run: echo "RELEASE_VERSION=${{ github.ref_name }}" >> $GITHUB_ENV

      - name: Create New Relic deployment marker
        uses: newrelic/deployment-marker-action@v2-beta
        with:
          apiKey: ${{ secrets.NEW_RELIC_API_KEY }}
          guid: ${{ secrets.NEW_RELIC_DEPLOYMENT_ENTITY_GUID }}
          version: "${{ env.RELEASE_VERSION }}"
```

#### All input options

Add a New Relic application deployment marker on release, with all of the
options set.

Github secrets assumed to be set:
* `NEW_RELIC_API_KEY` - Personal API key
* `NEW_RELIC_DEPLOYMENT_ENTITY_GUID` - New Relic Entity GUID to create the marker on

```yaml
name: Release
on:
  - release

jobs:
  newrelic:
    runs-on: ubuntu-latest
    steps:
      - name: Create New Relic deployment marker
        uses: newrelic/deployment-marker-action@v2-beta
        with:
          apiKey: ${{ secrets.NEW_RELIC_API_KEY }}
          guid: ${{ secrets.NEW_RELIC_DEPLOYMENT_ENTITY_GUID }}
          version: "${{ github.ref }}-${{ github.sha }}"
          commit: "${{ github.sha }}"

          # Optional
          changelog: "See https://github.com/${{ github.repository }}/blob/master/CHANGELOG.md for details"
          description: "Automated Deployment via Github Actions"
          region: ${{ secrets.NEW_RELIC_REGION }}
          user: "${{ github.actor }}"
```
