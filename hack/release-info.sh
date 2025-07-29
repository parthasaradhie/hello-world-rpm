#!/usr/bin/env bash
# Copyright The Conforma Contributors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# SPDX-License-Identifier: Apache-2.0

set -o errexit
set -o nounset
set -o pipefail

# Assumptions:
#  - at least one tag already exists

FILES_DIRS_TO_MONITOR="acceptance/ policy/"

CURRENT_COMMIT_SHA=$(git rev-parse HEAD)

# Obtain most recent tag
LATEST_TAG=$(git describe --tags --abbrev=0 --match="v[0-9]*" main)
LATEST_TAG_SHA=$(git rev-parse "$LATEST_TAG")

# if [ $CURRENT_COMMIT_SHA == $LATEST_TAG_SHA ]; then
#   echo "No changes since last version $LATEST_TAG"
#   exit 0
# fi

# check for changes in places of interest
DIFF=$(git diff --name-only $LATEST_TAG_SHA $FILES_DIRS_TO_MONITOR)
if [ -z "$DIFF" ]; then
  echo "The following paths haven't changed since last version $LATEST_TAG:"
  echo "$FILES_DIRS_TO_MONITOR"
  exit 0
fi

# bump version
# current_version=${LATEST_TAG#v*}
# IFS='.' read -r major minor patch <<< "$current_version"


NEXT_VERSION=$(echo "$LATEST_TAG" | awk -F. -v OFS=. '{$NF++;print}')
echo "Calculated next version: $NEXT_VERSION"

# Subtract 1 because we want the first build in main branch after the
# version bump to be X.Y.0
PATCH_NUM=$((${MERGES_SINCE_VERSION_BUMP} - 1))

# Handle edge case where $VERSION_FILE was modified in the current PR
[ $PATCH_NUM -lt 0 ] && PATCH_NUM=0

if [ ${PARENT_SHA_COUNT} -lt 2 ]; then
  # Must be a local build or a CI build in an unmerged PR.
  # Use something like v0.3.0-ci-eecf77f9
  SHORT_SHA=$(git rev-parse --short=8 HEAD)
  FULL_VERSION="v${MAJOR_MINOR}.${PATCH_NUM}-ci-${SHORT_SHA}"
else
  # Must be building on a merge commit
  # Use a short and tidy version, e.g. v0.3.0
  FULL_VERSION="v${MAJOR_MINOR}.${PATCH_NUM}"
fi

# Generally blank but will be set to "redhat" for Konflux builds
BUILD_SUFFIX="${1:-""}"

# This is build metadata in semver terms, see https://semver.org/#spec-item-10
if [ -n "${BUILD_SUFFIX}" ]; then
  FULL_VERSION="${FULL_VERSION}+${BUILD_SUFFIX}"
fi

echo ${FULL_VERSION}
