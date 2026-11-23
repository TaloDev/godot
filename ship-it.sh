#!/bin/bash

set -e

PLUGIN_CFG="addons/talo/plugin.cfg"
BUMP_TYPE=$1

case "$BUMP_TYPE" in
  major|minor|patch) ;;
  *)
    echo "Usage: $0 major|minor|patch"
    exit 1
    ;;
esac

VERSION=$(grep '^version=' "$PLUGIN_CFG" | sed 's/version="\(.*\)"/\1/')
IFS=. read -r MAJOR MINOR PATCH <<< "$VERSION"

case "$BUMP_TYPE" in
  major)
    MAJOR=$((MAJOR + 1))
    MINOR=0
    PATCH=0
    ;;
  minor)
    MINOR=$((MINOR + 1))
    PATCH=0
    ;;
  patch)
    PATCH=$((PATCH + 1))
    ;;
esac

NEW_VERSION="$MAJOR.$MINOR.$PATCH"

sed -i.bak -E "s/(^version=\")[^\"]+(\")/\1$NEW_VERSION\2/" "$PLUGIN_CFG"
rm -f "$PLUGIN_CFG.bak"

git add "$PLUGIN_CFG"
# the pre-commit hook syncs the version into talo_client.gd and stages it
git commit -m "$NEW_VERSION"

REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)

git push

gh pr create \
  --repo "$REPO" \
  --base main \
  --head develop \
  --title "Release $NEW_VERSION" \
  --label "release" \
  --body ""
