#!/usr/bin/env bash

echo 'Universal Node.js Linux Installer by github.com/taaem, updated by github.com/MichaIng'

show_help() {
    echo '
Use this script to install the latest official version available for your CPU architecture.
Alternatively install a specific unofficial build for rare architectures, using the parameters below.

Usage: ./node-install.sh [<params>]

Parameters:
  -h, --help                Show this help screen
  -l, --list                List all available Node.js versions, including official builds*
  -u, --unofficial          Include unofficial builds* as download source
  -v, --version <version>   Install specific version with <version> like "v15.5.1"

* Unofficial builds are available at unofficial-builds.nodejs.org
  and provide (newer) builds for rare, old or experimental architectures, like
  i386, armv6l or riscv64.'
}

error_exit() {
    echo "ERROR: $*" >&2
    exit 1
}

# curl and awk are required by this script
command -v 'curl' > /dev/null && command -v 'awk' > /dev/null || error_exit 'Required command line tools curl and/or awk not found'

# Detect architecture
ARCH=$(uname -m)

# Detect 64-bit kernel with 32-bit OS/userland: https://github.com/rust-lang/rustup/blob/5af9b94/rustup-init.sh#L193-L210
read -rN 5 bitness < /proc/self/exe
[[ $ARCH == 'aarch64' && $bitness == $'\177ELF\001' ]] && ARCH='armv7l'
[[ $ARCH == 'x86_64' && $bitness == $'\177ELF\001' ]] && ARCH='i386'

# Translate uname arch to Node.js arch
case $ARCH in
    'aarch64') ARCH='arm64';;
    'x86_64') ARCH='x64';;
    'i'[3-6]'86') ARCH='x86';;
    *) :;; # assume both to be the same
esac

# Official and unofficial base URLs
URL_OFFICIAL='https://nodejs.org/dist'
URL_UNOFFICIAL='https://unofficial-builds.nodejs.org/download/release'

list_available() {
    { curl -sSf "$URL_OFFICIAL/index.tab" | awk "\$3~/(^|,)linux-$ARCH(,|$)/{print \$1}"; curl -sSf "$URL_UNOFFICIAL/index.tab" | awk "\$3~/(^|,)linux-$ARCH(,|$)/{print \$1\" (unofficial)\"}"; } | sort -Vruk 1,1
}

# Getting options
UNOFFICIAL=0
VERSION=''
while (( $# )); do
    case $1 in
        '-h'|'--help')
            show_help
            exit 0
        ;;
        '-l'|'--list')
            echo 'The following Node.js versions are available. Unofficial builds from unofficial-builds.nodejs.org are marked with a trailing "(unofficial)".'
            list_available
            exit 0
        ;;
        '-u'|'--unofficial') UNOFFICIAL=1;;
        '-v'|'--version')
            shift
            VERSION=$1
            echo "Version \"$VERSION\" was requested"
        ;;
        '--') break;;
        *) error_exit "Unknown parameter \"$1\" given.";;
    esac
    shift
done

# Exit path for non-root executions
[[ $EUID == 0 ]] || error_exit 'root permissions required for installing Node.js, please execute this script with "sudo"'

# Download an xz archive if xz-utils are installed to save some traffic
EXT='gz'
command -v xz &> /dev/null && EXT='xz'

# Obtain version to download
if [[ $VERSION ]]; then
    echo "Searching build \"$VERSION\" for architecture \"$ARCH\" ..."
    if [[ $(curl -sSf "$URL_OFFICIAL/index.tab" | awk "\$1==\"$VERSION\" && \$3~/(^|,)linux-$ARCH(,|$)/") ]]; then
        URL="$URL_OFFICIAL/$VERSION/node-$VERSION-linux-$ARCH.tar.$EXT"
    elif [[ $UNOFFICIAL == 1 ]]; then
        echo "Searching unofficial build \"$VERSION\" for architecture \"$ARCH\" ..."
        if [[ $(curl -sSf "$URL_UNOFFICIAL/index.tab" | awk "\$1==\"$VERSION\" && \$3~/(^|,)linux-$ARCH(,|$)/") ]]; then
            URL="$URL_UNOFFICIAL/$VERSION/node-$VERSION-linux-$ARCH.tar.$EXT"
        else
            error_exit "Neither an official nor unofficial build \"$VERSION\" was found for architecture \"$ARCH\". Run \"./node-install.sh -l\" to list all available versions for your architecture."
        fi
    else
        error_exit "No official build \"$VERSION\" was found for architecture \"$ARCH\". Run \"./node-install.sh -l\" to list all available versions for your architecture. Run \"./node-install.sh -u -v $VERSION\" to install from unofficial builds if available."
    fi
else
    echo "Searching latest version for architecture \"$ARCH\" ..."
    if [[ $UNOFFICIAL == 1 ]]; then
        VERSION=$(list_available | head -1)
    else
        VERSION=$(list_available | grep -vm1 ' (unofficial)$')
    fi
    if [[ $VERSION == *' (unofficial)' ]]; then
        VERSION=${VERSION% (unofficial)}
        echo "Found latest unofficial build \"$VERSION\""
        URL="$URL_UNOFFICIAL/$VERSION/node-$VERSION-linux-$ARCH.tar.$EXT"
    elif [[ $VERSION ]]; then
        echo "Found latest official build \"$VERSION\""
        URL="$URL_OFFICIAL/$VERSION/node-$VERSION-linux-$ARCH.tar.$EXT"
    elif [[ $UNOFFICIAL == 1 ]]; then
        error_exit "Neither an official nor unofficial build was found for architecture \"$ARCH\"."
    else
        error_exit "No official build was found for architecture \"$ARCH\". Run \"./node-install.sh -l\" to check for unofficial builds, which can be installed with \"./node-install.sh -u\"."
    fi
fi

echo "Downloading $URL ..."
FILE_PATH="/tmp/node.tar.$EXT"
curl -fo "$FILE_PATH" "$URL" || error_exit "Failed to download $URL"
echo 'Finished downloading!'

echo 'Preparing install dir /usr/local ...'
[[ -d '/usr/local' ]] || mkdir /usr/local || error_exit 'Failed to create /usr/local'
cd /usr/local || error_exit 'Failed to enter /usr/local'

echo 'Cleaning up previous Node.js installation ...'
rm -Rf include/node lib/node_modules/{corepack,npm}

echo "Installing $FILE_PATH ..."
tar --strip-components=1 -xf "$FILE_PATH" || error_exit "Failed to extract $FILE_PATH"
rm -v "$FILE_PATH"
echo 'Finished installing!'

exit 0
