#!/bin/bash

echo 'Universal Node.js Linux Installer by github.com/taaem, updated by github.com/MichaIng'

show_help() {
    cat <<END

Use this script to install the latest official version available for your CPU architecture.
Alternatively install a specific unofficial build for rare architectures, using the parameters below.

Usage: node-install.sh [<params>]

Parameters:
    -h,  --help                     Show this help screen
    -lu, --list-unofficial          List all available versions in nodejs.org's unofficial builds
    -u,  --unofficial [<version>]   Install either latest version or <version> from nodejs.org's
                                    unofficial builds at unofficial-builds.nodejs.org/download/release/.
                                    Syntax of <version> shall be e.g. "v15.5.1".
END
}

ARCH=$(uname -m)
UNOFFICIALS_URI=https://unofficial-builds.nodejs.org/download/release

list_available() {
    if command -v 'curl' > /dev/null && command -v 'sort' > /dev/null; then
        if command -v 'tail' > /dev/null && command -v 'cut' > /dev/null; then
            curl -sSf $UNOFFICIALS_URI/index.tab | grep $ARCH | cut -f1 | tail -n +2 | sort -Vr
        # elif command -v 'jq' > /dev/null; then
        #     curl -sSf "$UNOFFICIALS_URI/index.json" | jq -r '.[].version' | sort -Vr
        else
            # echo 'ERROR: Required command line tools tail + cut, OR jq not found.' >&2
            echo 'ERROR: Required command line tools tail + cut not found.' >&2
            exit 1
        fi
    else
        echo 'ERROR: Required command line tools curl, sort not found.' >&2
        exit 1
    fi
}

# getting options
while [[ $1 ]]; do
    case $1 in
    -h | --help )
        show_help
        exit
        ;;
    -lu | --list-unofficial )
        list_available
        exit
        ;;
    -u | --unofficial )
        shift; unofficial_build_version=$1
        if [[ -z $unofficial_build_version ]]; then
            unofficial_build_version=$(curl -sSf $UNOFFICIALS_URI/index.tab | grep $ARCH | cut -f1 | tail -n +2 | sort -V | tail -n 1)
            echo "Found latest version $unofficial_build_version for architecture $ARCH."
        fi
        ;;
    -- )
        break
        ;;
    * )
        echo 'ERROR: Unkown parameter \"$1\" given.' >&2 && exit 1
    esac
    shift
done

if [[ $EUID != 0 ]]
    then
        echo 'root permissions required for installing Node.js'
        sudo echo 'sudo permissions verified'
        exit_status=$?
        if [[ $exit_status != 0 ]]
            then
            echo 'ERROR: Failed to get root permissions via "sudo"' >&2
            exit $exit_status
        fi
    else
        echo 'root permissions verified'
fi

if [[ $unofficial_build_version ]]; then
    echo "Searching version $unofficial_build_version for $ARCH ..."
    URL="$UNOFFICIALS_URI/${unofficial_build_version}/"
    NAME="node-${unofficial_build_version}-linux-${ARCH}.tar.gz"
    curl --output /dev/null --silent --head --fail "${URL}${NAME}" || NAME='' # check if file exists
    NAME="\"$NAME" # add double quote sign to mimic logic from original script block below.
else
    echo "Searching latest stable version for $ARCH ..."
    URL='https://nodejs.org/dist/'
    if [[ $ARCH == 'aarch64' ]]
    then
        URL+='latest/'
        NAME=$(curl -sSf "$URL" | grep -o '"node-v[0-9.]*-linux-arm64.tar.gz')

    elif [[ $ARCH == 'armv6l' ]]
    then
        URL+='latest-v11.x/'
        NAME=$(curl -sSf "$URL" | grep -o '"node-v[0-9.]*-linux-armv6l.tar.gz')

    elif [[ $ARCH == 'armv7l' ]]
    then
        URL+='latest/'
        NAME=$(curl -sSf "$URL" | grep -o '"node-v[0-9.]*-linux-armv7l.tar.gz')

    elif [[ $ARCH == 'x86_64' ]]
    then
        URL+='latest/'
        NAME=$(curl -sSf "$URL" | grep -o '"node-v[0-9.]*-linux-x64.tar.gz')

    elif [[ $ARCH == 'i'[3-6]'86' ]]
    then
        URL+='latest-v9.x/'
        NAME=$(curl -sSf "$URL" | grep -o '"node-v[0-9.]*-linux-x86.tar.gz')
    fi
fi
VER=${NAME:1}
if [[ ! $VER ]]
    then
        echo "ERROR: Failed to find latest stable version for $ARCH" >&2
        exit 1
fi
echo "Found latest stable version for $ARCH: $VER"

URL+=$VER
echo "Downloading $URL ..."
FILE_PATH='/tmp/node.tar.gz'
curl -fo "$FILE_PATH" "$URL"
exit_status=$?
if [[ $exit_status != 0 ]]
    then
        echo "ERROR: Failed to download $URL" >&2
        exit $exit_status
fi
echo 'Finished downloading!'

echo "Installing $FILE_PATH ..."
[[ -d '/usr/local' ]] || sudo mkdir /usr/local
cd /usr/local && sudo tar --strip-components=1 -xzf "$FILE_PATH"
exit_status=$?
if [[ $exit_status != 0 ]]
    then
        echo "ERROR: Failed to extract $FILE_PATH" >&2
        exit $exit_status
fi
rm -v "$FILE_PATH"
echo 'Finished installing!'

exit 0
