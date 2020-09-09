#!/bin/bash

echo 'Node.js Linux Installer by github.com/taaem, updated by github.com/MichaIng'
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

ARCH=$(uname -m)
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
