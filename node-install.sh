#!/usr/bin/env bash

echo 'Universal Node.js Linux Installer by github.com/taaem, updated by github.com/MichaIng'

show_help() {
    echo '
Use this script to install the latest official version available for your CPU architecture.
Alternatively install a specific unofficial build for rare architectures, using the parameters below.

Usage: node-install.sh [<params>]

Parameters:
    -h,  --help                     Show this help screen
    -lu, --list-unofficial          List all available versions in nodejs.org'\''s unofficial builds
    -u,  --unofficial [<version>]   Install either latest version or <version> from nodejs.org'\''s
                                    unofficial builds at unofficial-builds.nodejs.org/download/release/.
                                    Syntax of <version> shall be e.g. "v15.5.1".'
}

error_exit() {
    echo "ERROR: $*" >&2
    exit 1
}

ARCH=$(uname -m)
# Detect 64-bit kernel with 32-bit OS/userland: https://github.com/rust-lang/rustup/blob/5af9b94/rustup-init.sh#L193-L210
read -rN 5 bitness < /proc/self/exe
[[ $ARCH == 'aarch64' && $bitness == $'\177ELF\001' ]] && ARCH='armv7l'
[[ $ARCH == 'x86_64' && $bitness == $'\177ELF\001' ]] && ARCH='i386'
    
UNOFFICIALS_URI='https://unofficial-builds.nodejs.org/download/release'
UNOFFICIAL=0

list_available() {
    if command -v 'curl' > /dev/null && command -v 'awk' > /dev/null; then
        echo "The following unofficial build versions are available for $ARCH:"
        curl -sSf "$UNOFFICIALS_URI/index.tab" | awk "/$ARCH/{print \$1}"
    else
        error_exit 'Required command line tools curl + awk not found.'
    fi
}

# Getting options
while (( $# )); do
    case $1 in
    '-h'|'--help')
        show_help
        exit 0
        ;;
    '-lu'|'--list-unofficial')
        list_available
        exit 0
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
        error_exit "Unknown parameter \"$1\" given."
	;;
    esac
    shift
done

[[ $EUID == 0 ]] || error_exit 'root permissions required for installing Node.js, please execute this script with "sudo"'

# Download xz archive, if xz-utils are installed, to safe some traffic
EXT='gz'
command -v xz &> /dev/null && EXT='xz'

if [[ $UNOFFICIAL == 1 ]]; then
    if [[ $VER ]]; then
        echo "The following unofficial build version was requested: $VER"
    else
        echo "Searching latest unofficial build version for $ARCH ..."
        VER=$(curl -sSf "$UNOFFICIALS_URI/index.tab" | awk "/$ARCH/{print \$1;exit}")
        [[ $VER ]] || error_exit "Failed to find any unofficial build version for $ARCH"
        echo "Found latest unofficial build version for $ARCH: $VER"
    fi
    URL="$UNOFFICIALS_URI/$VER/node-$VER-linux-$ARCH.tar.$EXT"
else
    echo "Searching latest stable version for $ARCH ..."
    URL='https://nodejs.org/dist/'
    if [[ $ARCH == 'aarch64' ]]; then
        URL+='latest/'
        NAME=$(curl -sSf "$URL" | grep -o "\"node-v[0-9.]*-linux-arm64.tar.$EXT")
    elif [[ $ARCH == 'armv6l' ]]; then
        URL+='latest-v11.x/'
        NAME=$(curl -sSf "$URL" | grep -o "\"node-v[0-9.]*-linux-armv6l.tar.$EXT")
    elif [[ $ARCH == 'armv7l' ]]; then
        URL+='latest/'
        NAME=$(curl -sSf "$URL" | grep -o "\"node-v[0-9.]*-linux-armv7l.tar.$EXT")
    elif [[ $ARCH == 'x86_64' ]]; then
        URL+='latest/'
        NAME=$(curl -sSf "$URL" | grep -o "\"node-v[0-9.]*-linux-x64.tar.$EXT")
    elif [[ $ARCH == 'i'[3-6]'86' ]]; then
        URL+='latest-v9.x/'
        NAME=$(curl -sSf "$URL" | grep -o "\"node-v[0-9.]*-linux-x86.tar.$EXT")
    fi
    VER=${NAME:1}
    [[ $VER ]] || error_exit "Failed to find any stable version for $ARCH"
    echo "Found latest stable version for $ARCH: $VER"
    URL+=$VER
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
