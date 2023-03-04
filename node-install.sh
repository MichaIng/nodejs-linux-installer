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
UNOFFICIALS_URI='https://unofficial-builds.nodejs.org/download/release'
UNOFFICIAL=0

list_available() {
    if command -v 'curl' > /dev/null && command -v 'awk' > /dev/null; then
        echo "The following unofficial build versions are available for $ARCH:"
        curl -sSf "$UNOFFICIALS_URI/index.tab" | awk "/$ARCH/{print \$1}"
    else
        echo 'ERROR: Required command line tools curl + awk not found.' >&2
        exit 1
    fi
}

# Getting options
while [[ $1 ]]; do
    case $1 in
    '-h'|'--help')
        show_help
        exit
        ;;
    '-lu'|'--list-unofficial')
        list_available
        exit
        ;;
    '-u'|'--unofficial')
        UNOFFICIAL=1
        shift
        VER=$1
        ;;
    '--')
        break
        ;;
    *)
        echo "ERROR: Unkown parameter \"$1\" given." >&2
        exit 1
        ;;
    esac
    shift
done

if [[ $EUID != 0 ]]; then
    echo 'root permissions required for installing Node.js'
    sudo echo 'sudo permissions verified'
    exit_status=$?
    if [[ $exit_status != 0 ]]; then
        echo 'ERROR: Failed to get root permissions via "sudo"' >&2
        exit $exit_status
    fi
else
    echo 'root permissions verified'
fi

if [[ $UNOFFICIAL == 1 ]]; then
    if [[ $VER ]]; then
        echo "The following unofficial build version was requested: $VER"
    else
        echo "Searching latest unofficial build version for $ARCH ..."
        # RISC-V: Workaround until index.tab lists existing riscv64 builds: https://unofficial-builds.nodejs.org/download/release/index.tab
        VER=$(curl -sSf "$UNOFFICIALS_URI/index.tab" | awk "/${ARCH/riscv64/.*}/{print \$1;exit}")
        if [[ ! $VER ]]; then
            echo "ERROR: Failed to find any unofficial build version for $ARCH" >&2
            exit 1
        fi
        echo "Found latest unofficial build version for $ARCH: $VER"
    fi
    URL="$UNOFFICIALS_URI/$VER/node-$VER-linux-$ARCH.tar.gz"
else
    echo "Searching latest stable version for $ARCH ..."
    URL='https://nodejs.org/dist/'
    if [[ $ARCH == 'aarch64' ]]; then
        URL+='latest/'
        NAME=$(curl -sSf "$URL" | grep -o '"node-v[0-9.]*-linux-arm64.tar.gz')
    elif [[ $ARCH == 'armv6l' ]]; then
        URL+='latest-v11.x/'
        NAME=$(curl -sSf "$URL" | grep -o '"node-v[0-9.]*-linux-armv6l.tar.gz')
    elif [[ $ARCH == 'armv7l' ]]; then
        URL+='latest/'
        NAME=$(curl -sSf "$URL" | grep -o '"node-v[0-9.]*-linux-armv7l.tar.gz')
    elif [[ $ARCH == 'x86_64' ]]; then
        URL+='latest/'
        NAME=$(curl -sSf "$URL" | grep -o '"node-v[0-9.]*-linux-x64.tar.gz')
    elif [[ $ARCH == 'i'[3-6]'86' ]]; then
        URL+='latest-v9.x/'
        NAME=$(curl -sSf "$URL" | grep -o '"node-v[0-9.]*-linux-x86.tar.gz')
    fi
    VER=${NAME:1}
    if [[ ! $VER ]]; then
        echo "ERROR: Failed to find any stable version for $ARCH" >&2
        exit 1
    fi
    echo "Found latest stable version for $ARCH: $VER"
    URL+=$VER
fi

echo "Downloading $URL ..."
FILE_PATH='/tmp/node.tar.gz'
curl -fo "$FILE_PATH" "$URL"
exit_status=$?
if [[ $exit_status != 0 ]]; then
    echo "ERROR: Failed to download $URL" >&2
    exit $exit_status
fi
echo 'Finished downloading!'

echo "Installing $FILE_PATH ..."
[[ -d '/usr/local' ]] || sudo mkdir /usr/local
cd /usr/local && sudo tar --strip-components=1 -xzf "$FILE_PATH"
exit_status=$?
if [[ $exit_status != 0 ]]; then
    echo "ERROR: Failed to extract $FILE_PATH" >&2
    exit $exit_status
fi
rm -v "$FILE_PATH"
echo 'Finished installing!'

exit 0
