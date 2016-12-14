

![Localize](https://raw.githubusercontent.com/s4cha/AssetChecker/master/banner.png)

# AssetChecker
[![Language: Swift](https://img.shields.io/badge/language-swift-f48041.svg?style=flat)](https://developer.apple.com/swift)
![Platform: iOS](https://img.shields.io/badge/platform-iOS-blue.svg?style=flat)
[![codebeat badge](https://codebeat.co/badges/158a502c-1e18-4239-8301-a7ff79160b60)](https://codebeat.co/projects/github-com-s4cha-localize)
[![License: MIT](http://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat)](https://github.com/s4cha/Localize/blob/master/LICENSE)
[![Release version](https://img.shields.io/badge/release-0.1-blue.svg)]()

*AssetChecker* is a tiny run script that keeps your `Assets.xcassets` files clean and emits warnings when something is suspicious.


![AssetChecker](https://raw.githubusercontent.com/s4cha/AssetChecker/master/xcodeScreenshot.png)


## Why
Because **Image Assets** files are not safe, if an asset is ever deleted, nothing willl warn you that an image is broken in your code.

## How
By using a **script** running automatically, you have a **safety net** that makes using Asset Catalog a breeze.

## What

Automatically (On build)
  - Raises Errors for **Missing Assets**
  - Raises warnings for **Unused Assets**

## Installation

Add the following `Run Script` in XCode, this will run the script at every build.
Use the path of where you copied ImageAssetChecker script

```shell
${SRCROOT}/{PATH_TO_THE_SCRIPT}}/ImageAssetChecker.swift
```
Run and Enjoy \o/


## Author

Sacha Durand Saint Omer, sachadso@gmail.com

## Contributing

Contributions to AssetChecker are very welcomed and encouraged!

## License

AssetChecker is available under the MIT license. See [LICENSE](https://github.com/s4cha/AssetChecker/blob/master/LICENSE) for more information.
