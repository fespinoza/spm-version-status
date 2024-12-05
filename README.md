# Package Status

A command line utility to check the latest versions available for the SPM packages declared as depedency in your Xcode Project or SPM package.

Initial idea and reference taken from: https://github.com/gorillatech/spm-check-updates

## Installation

Compile the script
```bash
swift build --configuration release
sudo cp -f .build/release/SPMVersionStatus /usr/local/bin/spm-version-status
```

## Usage

```bash
spm-version-status
```

## Development

```bash
swift run SPMVersionStatus
```
