#!/bin/bash

# Check whether to use latest version of PMD
if [ "$SPOTBUGS_VERSION" == 'latest' ]; then
    LATEST_TAG="$(curl -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/spotbugs/spotbugs/releases/latest | jq --raw-output '.tag_name')"
    SPOTBUGS_VERSION=$LATEST_TAG
fi

# Download SpotBugs
wget https://github.com/spotbugs/spotbugs/releases/download/"${SPOTBUGS_VERSION}"/spotbugs-"${SPOTBUGS_VERSION}".zip
unzip spotbugs-"${SPOTBUGS_VERSION}".zip

# Run SpotBugs
SPOTBUGS_HOME=spotbugs-"${SPOTBUGS_VERSION}"
SPOTBUGS=${SPOTBUGS_HOME}/bin/spotbugs
sh $SPOTBUGS -textui -output "${OUTPUT}" "${ARGUMENTS}" "${TARGET}"
