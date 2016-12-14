#!/usr/bin/env xcrun --sdk macosx swift

import Foundation

// Configure me \o/
let sourcePath = "/Sources"
let assetCatalogPath = "/Resources/Assets.xcassets"



// MARK : - End Of Configurable Sexction

func listAssets() -> [String] {
    var assetNames = [String]()
    let path = FileManager.default.currentDirectoryPath + assetCatalogPath
    let enumerator: FileManager.DirectoryEnumerator? = FileManager.default.enumerator(atPath: path)
    let extensionName = "imageset"
    while let element = enumerator?.nextObject() as? String {
        if element.hasSuffix(extensionName) {
            let name = element.replacingOccurrences(of: ".\(extensionName)", with: "")
            assetNames.append(name)
        }
    }
    return assetNames
}

func listUsedAssetLiterals() -> [String] {
    let patterns = [
        "#imageLiteral\\(resourceName: \"(\\w+)\"\\)" // Image Literal
    ]
    let sourcesPath = FileManager.default.currentDirectoryPath + sourcePath
    let fileManager = FileManager.default
    let enumerator = fileManager.enumerator(atPath:sourcesPath)
    var localizedStrings = [String]()
    while let swiftFileLocation = enumerator?.nextObject() as? String {
        // checks the extension // TODO OBJC?
        if swiftFileLocation.hasSuffix(".swift") || swiftFileLocation.hasSuffix(".m") {
            let location = "\(sourcesPath)/\(swiftFileLocation)"
            if let string = try? String(contentsOfFile: location, encoding: .utf8) {
                for p in patterns {
                    let regex = try? NSRegularExpression(pattern: p, options: [])
                    let range = NSRange(location:0, length:(string as NSString).length) //Obj c wa
                    regex?.enumerateMatches(in: string,
                                            options: [],
                                            range: range,
                                            using: { (result, _, _) in
                                                if let r = result {
                                                    let value = (string as NSString).substring(with:r.rangeAt(1))
                                                    localizedStrings.append(value)
                                                }
                    })
                }
            }
        }
    }
    return localizedStrings
}







let assets = Set(listAssets())
let used = Set(listUsedAssetLiterals())


// Generate Warnings for Unused Assets
let unused = assets.subtracting(used)
unused.forEach { assetName in
    var path = FileManager.default.currentDirectoryPath + assetCatalogPath
    print("\(path):: warning: [Asset Unused] \(assetName)")
}


// Generate Error for broken Assets
let broken = used.subtracting(assets)
broken.forEach { assetName in
    var path = FileManager.default.currentDirectoryPath + assetCatalogPath
    print("\(path):: error: [Asset Missing] \(assetName)")
}

if broken.count > 0 {
    exit(1)
}

// TODO unsused get file and line
