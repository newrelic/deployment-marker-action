[![Community Project header](https://github.com/newrelic/open-source-office/raw/master/examples/categories/images/Community_Project.png)](https://github.com/newrelic/open-source-office/blob/master/examples/categories/index.md#category-community-project)

# New Relic Application Deployment Marker

[![GitHub Marketplace version](https://img.shields.io/github/release/newrelic/deployment-marker-action.svg?label=Marketplace&logo=github)](https://github.com/marketplace/actions/new-relic-application-deployment-marker)

A GitHub Action to add New Relic deployment markers during your release pipeline.

> Deployment Markers are only supported by APM Applications.

## Inputs

| Key             | Required | Default | Description |
| --------------- | -------- | ------- | ----------- |
| `accountId`     | **yes**  | -       | The account number the application falls under. This could also be a subaccount. |
| `apiKey`        | **yes**  | -       | Your New Relic [personal API key](https://docs.newrelic.com/docs/apis/get-started/intro-apis/types-new-relic-api-keys#personal-api-key). |
| `applicationId` | **yes**  | -       | The New Relic application ID to apply the deployment marker. |
| `changelog`     | no       | -       | A summary of what changed in this deployment, visible in the Deployments page. |
| `description`   | no       | -       | A high-level description of this deployment, visible in the Overview page and on the Deployments page when you select an individual deployment. |
| `region`        | no       | `US`    | The region of your New Relic account. Default: `US` |
| `revision`      | **yes**  | -       | Metadata to apply to the deployment marker - e.g. the latest release tag |
| `user`          | no       | `github.actor` | A username to associate with the deployment, visible in the Overview page and on the Deployments page. |

## Example usage

#### Use Release Tag for Revision

The following example could be added as a job to your existing workflow that
creates a New Relic deployment marker with the revision being the release Tag.

Github secrets assumed to be set:
* `NEW_RELIC_ACCOUNT_ID` - New Relic Account ID the application is reporting to
* `NEW_RELIC_API_KEY` - Personal API key
* `NEW_RELIC_APPLICATION_ID` - New Relic Application ID to create the marker on

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
        run: echo "RELEASE_VERSION=${{ GITHUB_REF:10 }}" >> $GITHUB_ENV

      - name: Create New Relic deployment marker
        uses: newrelic/deployment-marker-action@v1
        with:
          apiKey: ${{ secrets.NEW_RELIC_API_KEY }}
          accountId: ${{ secrets.NEW_RELIC_ACCOUNT_ID }}
          applicationId: ${{ secrets.NEW_RELIC_APPLICATION_ID }}
          revision: "${{ env.RELEASE_VERSION }}"
```

#### All input options

Add a New Relic application deployment marker on release, with all of the
options set.

Github secrets assumed to be set:
* `NEW_RELIC_ACCOUNT_ID` - New Relic Account ID the application is reporting to
* `NEW_RELIC_API_KEY` - Personal API key
* `NEW_RELIC_APPLICATION_ID` - New Relic Application ID to create the marker on

```yaml
name: Release
on:
  - release

jobs:
  newrelic:
    runs-on: ubuntu-latest
    steps:
      - name: Create New Relic deployment marker
        uses: newrelic/deployment-marker-action@v1
        with:
          accountId: ${{ secrets.NEW_RELIC_ACCOUNT_ID }}
          apiKey: ${{ secrets.NEW_RELIC_API_KEY }}
          applicationId: ${{ secrets.NEW_RELIC_APPLICATION_ID }}
          revision: "${{ github.ref }}-${{ github.sha }}"

          # Optional
          changelog: "See https://github.com/${{ github.repository }}/blob/master/CHANGELOG.md for details"
          description: "Automated Deployment via Github Actions"
          region: ${{ secrets.NEW_RELIC_REGION }}
          user: "${{ github.actor }}"
```
