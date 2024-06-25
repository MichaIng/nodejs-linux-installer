# Node.js Linux Installer

This is a universal Node.js installer for Linux. The [original project by taaem](https://github.com/taaem/nodejs-linux-installer) required some fixes to maintain functionality, which are contained in this fork, along with other enhancements and support for [nodejs.org's unofficial builds](https://github.com/nodejs/unofficial-builds/).

[![CodeFactor](https://www.codefactor.io/repository/github/michaing/nodejs-linux-installer/badge)](https://www.codefactor.io/repository/github/michaing/nodejs-linux-installer)

The following architectures are supported:
- ARMv6 (armv6l)*
- ARMv7 (armv7l)
- ARMv8 (aarch64)
- x86 64-bit (x86_64)
- x86 32-bit (i386, i486, i586, i686)**
- further architectures from [nodejs.org's unofficial builds](https://github.com/nodejs/unofficial-builds/).

\* *The latest official version for ARMv6 is Node v11. For more recent versions, use unofficial builds.*  
\*\* *The latest official version for x86 32-bit is Node v9. For more recent versions, use unofficial builds.*

## Usage

**I don't take any responsibilities if you blow your system up!**

*Please be aware, that installing Node.js requires **root privileges**. The script will check for root or sudo credentials at start.*

By default the latest (official) version available for your architecture will be installed:

```sh
curl -sSf 'https://raw.githubusercontent.com/MichaIng/nodejs-linux-installer/master/node-install.sh' | bash
```

Show a list of all versions available for your architecture, including unofficial builds from [nodejs.org](https://unofficial-builds.nodejs.org/download/release/):

```sh
curl -sSf 'https://raw.githubusercontent.com/MichaIng/nodejs-linux-installer/master/node-install.sh' | bash -s -- --list
```

Install a specific (official) version `<version>`:

```sh
curl -sSf 'https://raw.githubusercontent.com/MichaIng/nodejs-linux-installer/master/node-install.sh' | bash -s -- --version '<version>'
```

#### If no (recent) official builds are available for your architecture, you may install [nodejs.org's unofficial builds](https://github.com/nodejs/unofficial-builds/), using the options below.

Install a specific unofficial version `<version>`:

```sh
curl -sSf 'https://raw.githubusercontent.com/MichaIng/nodejs-linux-installer/master/node-install.sh' | bash -s -- --unofficial --version '<version>'
```

Install the latest version available for your architecture, no matter whether official or unofficial:

```sh
curl -sSf 'https://raw.githubusercontent.com/MichaIng/nodejs-linux-installer/master/node-install.sh' | bash -s -- --unofficial'
```

Get the help text:

```sh
curl -sSf 'https://raw.githubusercontent.com/MichaIng/nodejs-linux-installer/master/node-install.sh' | bash -s -- --help
```

## Contributing

Just create a fork and please contribute all your improvements back here!

## License

[MIT](https://github.com/MichaIng/nodejs-linux-installer/blob/master/LICENSE)

Thanks for all contributions!
