#!/bin/bash

set -e

VERSION_FILE="VERSION"
DO_COMMIT=${DO_COMMIT:-false}

if [ ! -f "$VERSION_FILE" ]; then
  echo "0.0.0" > $VERSION_FILE
fi

current_version=$(cat $VERSION_FILE)
IFS='.' read -r major minor patch <<< "$current_version"

release_type=$1

if [[ -z "$release_type" ]]; then
  echo "Usage: $0 [major|minor|patch]"
  exit 1
fi

case "$release_type" in
  major)
    major=$((major + 1))
    minor=0
    patch=0
    ;;
  minor)
    minor=$((minor + 1))
    patch=0
    ;;
  patch)
    patch=$((patch + 1))
    ;;
  *)
    echo "Invalid release type. Use: major, minor, or patch."
    exit 1
    ;;
esac

new_version="$major.$minor.$patch"

echo "Current version: $current_version"
echo "New version: $new_version"

echo "$new_version" > $VERSION_FILE

# Commit changes
if [[ "$DO_COMMIT" != "true"]]; then
    echo "Skipping commit and tag creation. Set DO_COMMIT=true to create commit and a tag."
    echo "✅ Version file updated"
    exit
fi

git add $VERSION_FILE
#git commit -m "chore: Bump $release_type version to v$new_version" \
#    -m 'Commit generated with `$0`'

#git tag -a "v$new_version" -m "Release version v$new_version"

#git push origin main --tags

echo "✅ Release v$new_version created and pushed successfully."

