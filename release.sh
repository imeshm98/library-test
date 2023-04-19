#!/bin/bash

# Set variables
LIB_NAME="my-app"
BUCKET_NAME="my-app-repo"
RELEASE_FOLDER="releases"
SNAPSHOT_FOLDER="snapshots"
RELEASE_TYPE=$1

BRANCH_NAME=$(git branch --show-current)
if [ "$BRANCH_NAME" != "main" ]; then
    echo "You can only run script from 'main' branch. Switch to the 'main' branch"
    exit 1
fi

if [[ $(git branch --list development) ]]; then
    git checkout development origin/development
else
    git checkout -b development origin/development
fi

# Snapshot from Development Branch
# Get the current version from the POM file
if ! mvn deploy -DaltDeploymentRepository="s3-repo::default::s3://${BUCKET_NAME}/${SNAPSHOT_FOLDER}"; then
    echo "Failed to deploy snapshot JAR to S3"
    exit 1
fi

# Release from Main Branch
git checkout main

# Get the current version from the POM file
CURRENT_VERSION=$(mvn help:evaluate -Dexpression=project.version -q -DforceStdout)

# Get version to an array
IFS='.' read -ra VERSION_PARTS <<< "$CURRENT_VERSION"
MAJOR_VERSION=${VERSION_PARTS[0]}
MINOR_VERSION=${VERSION_PARTS[1]}
PATCH_VERSION=${VERSION_PARTS[2]}

# Check the release type and increase the version
if [ "$RELEASE_TYPE" == "patch" ]; then
    NEW_VERSION="$MAJOR_VERSION.$MINOR_VERSION.$((PATCH_VERSION + 1))"
elif [ "$RELEASE_TYPE" == "minor" ]; then
    NEW_VERSION="$MAJOR_VERSION.$((MINOR_VERSION + 1)).0"
elif [ "$RELEASE_TYPE" == "major" ]; then
    NEW_VERSION="$((MAJOR_VERSION + 1)).0.0"
else 
    echo "Use patch, minor or major as parameters. (eg:- ./release.sh patch)"
    exit 1
fi

# Replace the version in the POM file with the new release version
mvn versions:set -DnewVersion=$NEW_VERSION

if ! mvn deploy -DaltDeploymentRepository="s3-repo::default::s3://${BUCKET_NAME}/${RELEASE_FOLDER}"; then
    echo "Failed to deploy release JAR to S3"
    exit 1
fi

# Replace the version in the POM file with the new snapshot version
mvn versions:set -DnewVersion="$NEW_VERSION-SNAPSHOT"

# Commit and push changes to GitHub main branch
git add .
git commit -m "Released new version"
git push origin main
git tag $NEW_VERSION
git push origin $NEW_VERSION