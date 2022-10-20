#!/bin/bash

# set com.example.demo and all chid packages (.- means all children, .* this package only)
# PACKAGES="com.example.demo.-"
# source path to prepend to the class path
# BASEPATH="src/main/java"
# DEPENDENCIES_PATH="~/.m2"
# OUTPUT_TYPE="sarif"

# Check whether to use latest version of PMD
if [ "$SPOTBUGS_VERSION" == 'latest' ] || [ "$SPOTBUGS_VERSION" == "" ]; then
    LATEST_TAG="$(curl -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/spotbugs/spotbugs/releases/latest | jq --raw-output '.tag_name')"
    SPOTBUGS_VERSION=$LATEST_TAG
fi

# Download SpotBugs
wget -q -N https://github.com/spotbugs/spotbugs/releases/download/"${SPOTBUGS_VERSION}"/spotbugs-"${SPOTBUGS_VERSION}".zip
unzip -q -o spotbugs-"${SPOTBUGS_VERSION}".zip

# Run SpotBugs
SPOTBUGS_HOME=spotbugs-"${SPOTBUGS_VERSION}"
SPOTBUGS=${SPOTBUGS_HOME}/bin/spotbugs

#sh $SPOTBUGS -textui -output "${OUTPUT}" "${ARGUMENTS}" "${TARGET}"

# Take care of parameter order, sometimes does not work if you change it

CMD="java -Xmx1900M -Dlog4j2.formatMsgNoLookups=true \
  -jar ${SPOTBUGS_HOME}/lib/spotbugs.jar -textui "

if [ "$PACKAGES" != "" ]; then
    CMD="$CMD -onlyAnalyze ${PACKAGES}"
fi

CMD="$CMD -quiet -effort:max -low -noClassOk"

case $OUTPUT_TYPE in
    "xml")
        if [ "$OUTPUT" == "" ]; then
            OUTPUT="results.xml"
        fi
        CMD="$CMD -xml:withMessages=./$OUTPUT"
        ;;
    "html")
        if [ "$OUTPUT" == "" ]; then
            OUTPUT="results.html"
        fi
        CMD="$CMD -html:withMessages=./$OUTPUT"
        ;;
    "emacs")
        if [ "$OUTPUT" == "" ]; then
            OUTPUT="results.emacs"
        fi
        CMD="$CMD -emacs:withMessages=./$OUTPUT"
        ;;
    "xdocs")
        if [ "$OUTPUT" == "" ]; then
            OUTPUT="results.xdocs"
        fi
        CMD="$CMD -xdoc:withMessages=./$OUTPUT"
        ;;
    *)
        OUTPUT_TYPE="sarif"
        if [ "$OUTPUT" == "" ]; then
            OUTPUT="results.sarif"
        fi
        CMD="$CMD -sarif:withMessages=./resultspre.sarif"
        ;;
esac

if [ "$DEPENDENCIES_PATH" != "" ]; then
    DEP_CMD="find ${DEPENDENCIES_PATH} -name \"*.jar\" -type f > /tmp/jardependencies.txt"
    echo "Scanning jars with: ${DEP_CMD}"
    eval ${DEP_CMD}
    CMD="$CMD -auxclasspathFromFile /tmp/jardependencies.txt"
fi

if [ "$BASE_PATH" != "" ]; then
    if [[ "$BASE_PATH" != */ ]]; then
        BASE_PATH="$BASE_PATH/"
    fi
    # using sourcepath does not work for GitHub's sarif parser
    # but keeping there just in case
    CMD="$CMD -sourcepath ${BASE_PATH}"
fi

if [ "$ARGUMENTS" != "" ]; then
    CMD="$CMD ${ARGUMENTS}"
fi

if [ "$TARGET" != "" ]; then
    CMD="$CMD ${TARGET}"
else
    CMD="$CMD ."
fi

echo "Running SpotBugs with command: $CMD"

eval ${CMD}

if [ "$OUTPUT_TYPE" == "sarif" ] && [ "$BASE_PATH" != "" ]; then
    # prepend the pyhsical path
    echo "Transform sarif file to include the physical path"
    cat resultspre.sarif | jq -c "(.runs[].results[].locations[].physicalLocation.artifactLocation.uri) |=\"$BASE_PATH\"+." > resultspre2.sarif
    cat resultspre2.sarif | jq -c '(.runs[].invocations[].executionSuccessful)=true' > results.sarif
fi

