#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

# Define target branch (usually main or master)
TARGET_BRANCH=$(git symbolic-ref --short HEAD 2>/dev/null || echo "main")

# Check if we are on a clean working directory
if [ -n "$(git status --porcelain)" ]; then
  echo "⚠️ Warning: You have uncommitted changes."
  read -p "Do you want to proceed and include these changes in the release commit? (y/N) " confirm
  if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Release aborted."
    exit 1
  fi
fi

# Fetch latest version from pubspec.yaml
VERSION_LINE=$(grep '^version: ' pubspec.yaml)
if [ -z "$VERSION_LINE" ]; then
  echo "❌ Error: Could not find version in pubspec.yaml"
  exit 1
fi

VERSION_FULL=${VERSION_LINE#version: }
VERSION_PART=${VERSION_FULL%+*}
BUILD_PART=${VERSION_FULL#*+}

# Parse version components
IFS='.' read -r major minor patch <<< "$VERSION_PART"

# Ask user for bump type
echo "Current version is: $VERSION_FULL"
echo "Select version bump type:"
echo "1) Patch (e.g. 1.0.5 -> 1.0.6)"
echo "2) Minor (e.g. 1.0.5 -> 1.1.0)"
echo "3) Major (e.g. 1.0.5 -> 2.0.0)"
read -p "Choose option [1-3, default 1]: " option

case $option in
  2)
    minor=$((minor + 1))
    patch=0
    ;;
  3)
    major=$((major + 1))
    minor=0
    patch=0
    ;;
  *)
    patch=$((patch + 1))
    ;;
esac

NEW_BUILD=$((BUILD_PART + 1))
NEW_VERSION="$major.$minor.$patch"
NEW_VERSION_FULL="$NEW_VERSION+$NEW_BUILD"

echo "Bumping version to: $NEW_VERSION_FULL"

# Update version in pubspec.yaml
sed -i '' "s/^version: .*/version: $NEW_VERSION_FULL/" pubspec.yaml

# Commit, tag and push
git add pubspec.yaml
git commit -m "chore: release v$NEW_VERSION_FULL"
git tag "v$NEW_VERSION"

echo "🚀 Pushing branch $TARGET_BRANCH and tag v$NEW_VERSION to origin..."
git push origin "$TARGET_BRANCH"
git push origin "v$NEW_VERSION"

echo "✅ Release successfully pushed! GitHub Actions will now build the Windows installer and ZIP artifacts."
