# Node.js Linux Installer
This is a universal Node.js installer for Linux. The [original project by taaem](https://github.com/taaem/nodejs-linux-installer) required some fixes to maintain functionality, which are contained in this fork, together with a few enhancements.

[![CodeFactor](https://www.codefactor.io/repository/github/michaing/nodejs-linux-installer/badge)](https://www.codefactor.io/repository/github/michaing/nodejs-linux-installer)

The following architectures are currently supported:
- ARMv6 (armv6l)*
- ARMv7 (armv7l)
- ARMv8 (aarch64)
- x86 64-bit (x86_64)
- x86 32-bit (i386, i486, i586, i686)**
- further architectures from [nodejs.org's unofficial builds](unofficial-builds.nodejs.org).

\* The latest official version for ARMv6 is Node v11. For more recent versions, use unofficial builds.  
\*\* The latest official version for x86 32-bit is Node v9. For more recent versions, use unofficial builds.

**I don't take any responsibilities if you blow your system up!**

### Usage
Please be aware, that installing Node requires root privileges. The script will check for root or sudo credentials at start.
By default the latest official release for your architecture will be installed. If no (recent) official build is available for your architecture, you may install unofficial builds, using the options below.

Get the help text:

    curl -sSf https://raw.githubusercontent.com/MichaIng/nodejs-linux-installer/master/node-install.sh | bash -s -- --help

Show a list of all unofficial releases for your CPU architecture available from nodejs.org :

    curl -sSf https://raw.githubusercontent.com/MichaIng/nodejs-linux-installer/master/node-install.sh | bash -s -- --list-unofficial-releases

Install unofficial release of node.js with `<version>`:

    curl -sSf https://raw.githubusercontent.com/MichaIng/nodejs-linux-installer/master/node-install.sh | bash -s -- --unofficial-version <version>


### Contributing
Just create a fork and please contribute all your improvements back here!

### License
MIT

Thanks for all contributions!
