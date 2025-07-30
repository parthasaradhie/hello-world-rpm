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

TRACKED_FILES_DIRS=$TRACKED_FILES_DIRS

# Obtain most recent tag
LATEST_TAG=$(git describe --tags --abbrev=0 --match="v[0-9]*" main)
LATEST_TAG_SHA=$(git rev-parse "$LATEST_TAG")

# check for changes since last version
HAS_CHANGES=false
DIFF=$(git diff --name-only $LATEST_TAG_SHA $TRACKED_FILES_DIRS)
[ -z "$DIFF" ] || HAS_CHANGES=true

# bump patch version
NEXT_VERSION=$(echo "$LATEST_TAG" | awk -F. -v OFS=. '{$NF++;print}')
# the last line
