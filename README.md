# Node.js Linux Installer
This is a universal Node.js installer for Linux. The [original project by taaem](https://github.com/taaem/nodejs-linux-installer) required some fixes to maintain functionality, which are contained in this fork, together with a few enhancements.

The following architectures are currently supported:
- ARMv6 (armv6l)
- ARMv7 (armv7l)
- ARMv8 (aarch64)
- x86 64-bit (x86_64)
- x86 32-bit (i386, i486, i586, i686)
- further architectures from [nodejs.org's unofficial builds](unofficial-builds.nodejs.org).

**I don't take any responsibilities if you blow your system up!**

### Usage
Please be aware, that installation of node requires root privileges. The script will ask for sudo credentials before installation.

Get the help text:

    curl -sSf https://raw.githubusercontent.com/ollliegits/nodejs-linux-installer/master/node-install.sh | bash -s -- --help

Show a list of all unofficial releases for your CPU architecture available from nodejs.org :

    curl -sSf https://raw.githubusercontent.com/ollliegits/nodejs-linux-installer/master/node-install.sh | bash -s -- --list-unofficial-releases

Install unofficial release of node.js with `<version>`:

    curl -sSf https://raw.githubusercontent.com/ollliegits/nodejs-linux-installer/master/node-install.sh | bash -s -- --unofficial-version <version>


### Contributing
Just create a fork and please contribute all your improvements back here!

### License
MIT

Thanks for all contributions
