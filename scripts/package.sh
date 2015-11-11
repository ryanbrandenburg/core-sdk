#!/usr/bin/env bash

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
REPOROOT="$( cd -P "$DIR/.." && pwd )"

source "$DIR/_common.sh"

OUTPUT_ROOT=$REPOROOT/artifacts/$RID
STAGE2_DIR=$OUTPUT_ROOT/stage2

echo "Starting packaging"

if [ -z "$DOTNET_BUILD_VERSION" ]; then
    TIMESTAMP=$(date "+%Y%m%d%H%M%S")
    export DOTNET_BUILD_VERSION=0.0.1-alpha-t$TIMESTAMP
    echo "Version: $DOTNET_BUILD_VERSION"
fi

COMMIT=$(git rev-parse HEAD)
echo $COMMIT > $STAGE2_DIR/.version
echo $DOTNET_BUILD_VERSION >> $STAGE2_DIR/.version

# Create Dnvm Package
$DIR/package-dnvm.sh

if [[ "$(uname)" == "Linux" ]]; then
    # Create Debian package
    $DIR/package-debian.sh
fi

$DIR/../packaging/osx/package-osx.sh
