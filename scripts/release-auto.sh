#!/bin/bash

COLOR_RED='\033[0;31m'
COLOR_NONE='\033[0m'

DEFAULT_BRANCH='main'
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

SCRIPT_NAME=$(basename -- "$0")

echo "Current branch: ${CURRENT_BRANCH}"
echo "Default branch: ${DEFAULT_BRANCH}"

if [ $CURRENT_BRANCH != $DEFAULT_BRANCH ]; then
  printf "\n"
  printf "${COLOR_RED} Error: ${SCRIPT_NAME} must be run on main branch.\n ${COLOR_NONE}"
  printf "\n"
  exit 1
fi

# Set GOBIN env variable for Go dependencies
GOBIN=$(go env GOPATH)/bin

# Install release dependencies
go install github.com/caarlos0/svu@latest
go install github.com/git-chglog/git-chglog/cmd/git-chglog@latest
go install github.com/client9/misspell/cmd/misspell@latest

VER_CMD=${GOBIN}/svu
CHANGELOG_CMD=${GOBIN}/git-chglog
CHANGELOG_FILE=CHANGELOG.md
SPELL_CMD=${GOBIN}/misspell

# Compare versions
VER_CURR=$(${VER_CMD} current)
VER_NEXT=$(${VER_CMD} next)

echo ""
echo "Comparing tag versions... current: ${VER_CURR}, next: ${VER_NEXT}"
echo ""

if [ "${VER_CURR}" = "${VER_NEXT}" ]; then
    VER_NEXT=$(${VER_CMD} patch)
    printf "Bumping current version ${COLOR_GREEN}${VER_CURR}${COLOR_NONE} to version ${COLOR_LIGHT_GREEN}${VER_NEXT}${COLOR_NONE} for release. "
fi

GIT_USER=$(git config user.name)
GIT_EMAIL=$(git config user.email)

if [ -z "${GIT_USER}" ]; then
  echo "git user.name not set"
  exit 1
fi

if [ -z "${GIT_EMAIL}" ]; then
  echo "git user.email not set"
  exit 1
fi

echo "Generating release for ${VER_NEXT} using git user ${GIT_USER}"

# Auto-generate CHANGELOG updates
${CHANGELOG_CMD} --next-tag ${VER_NEXT} -o ${CHANGELOG_FILE}
${SPELL_CMD}  -source text -w ${CHANGELOG_FILE}

# Commit CHANGELOG updates
git add CHANGELOG.md
git commit --no-verify -m "chore(changelog): Update CHANGELOG for ${VER_NEXT}"
git push --no-verify origin HEAD:${DEFAULT_BRANCH}

# print an error message in case of failure, if the changes to the changelog cannot be committed to main
if [ $? -ne 0 ]; then
  echo "Failed to push branch updates, exiting"
  exit 1
fi

# Create and push new tag
git tag ${VER_NEXT}
git push --no-verify origin HEAD:${DEFAULT_BRANCH} --tags

if [ $? -ne 0 ]; then
  echo "Failed to push tag, exiting"
  exit $?
fi
