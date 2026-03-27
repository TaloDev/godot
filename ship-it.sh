#!/bin/bash

VERSION=$(grep '^version=' addons/talo/plugin.cfg | sed 's/version="\(.*\)"/\1/')
REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)

gh pr create \
  --repo "$REPO" \
  --base main \
  --head develop \
  --title "Release $VERSION" \
  --label "release" \
  --body ""
