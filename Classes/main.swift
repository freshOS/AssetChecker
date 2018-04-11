#!/usr/bin/env xcrun --sdk macosx swift

import Foundation

// Configure me \o/
var sourcePathOption:String? = nil
var assetCatalogPathOption:String? = nil
let ignoredUnusedNames = [String]()

for (index, arg) in CommandLine.arguments.enumerated() {
    switch index {
    case 1:
        sourcePathOption = arg
    case 2:
        assetCatalogPathOption = arg
    default:
        break
    }
}

guard let sourcePath = sourcePathOption else {
    print("AssetChecker:: error: Source path was missing!")
    exit(0)
}

guard let assetCatalogAbsolutePath = assetCatalogPathOption else {
    print("AssetChecker:: error: Asset Catalog path was missing!")
    exit(0)
}

print("Searching sources in \(sourcePath) for assets in \(assetCatalogAbsolutePath)")

/* Put here the asset generating false positives, 
 For instance whne you build asset names at runtime
let ignoredUnusedNames = [
    "IconArticle",
    "IconMedia",
    "voteEN",
    "voteES",
    "voteFR"
] 
*/


// MARK : - End Of Configurable Section

func elementsInEnumerator(_ enumerator: FileManager.DirectoryEnumerator?) -> [String] {
    var elements = [String]()
    while let e = enumerator?.nextObject() as? String {
        elements.append(e)
    }
    return elements
}


// MARK: - List Assets

func listAssets() -> [String] {
    let extensionName = "imageset"
    let enumerator = FileManager.default.enumerator(atPath: assetCatalogAbsolutePath)
    return elementsInEnumerator(enumerator)
        .filter { $0.hasSuffix(extensionName) }                             // Is Asset
        .map { $0.replacingOccurrences(of: ".\(extensionName)", with: "") } // Remove extension
        .map { $0.components(separatedBy: "/").last ?? $0 }                 // Remove folder path
}


// MARK: - List Used Assets in the codebase

func localizedStrings(inStringFile: String) -> [String] {
    var localizedStrings = [String]()
    let namePattern = "([\\w-]+)"
    let patterns = [
        "#imageLiteral\\(resourceName: \"\(namePattern)\"\\)", // Image Literal
        "UIImage\\(named:\\s*\"\(namePattern)\"\\)", // Default UIImage call (Swift)
        "UIImage imageNamed:\\s*\\@\"\(namePattern)\"", // Default UIImage call 
        "\\<image name=\"\(namePattern)\".*", // Storyboard resources
        "R.image.\(namePattern)\\(\\)" //R.swift support
    ]
    for p in patterns {
        let regex = try? NSRegularExpression(pattern: p, options: [])
        let range = NSRange(location:0, length:(inStringFile as NSString).length)
        regex?.enumerateMatches(in: inStringFile,options: [], range: range) { result, _, _ in
            if let r = result {
                let value = (inStringFile as NSString).substring(with:r.range(at: 1))
                localizedStrings.append(value)
            }
        }
    }
    return localizedStrings
}

func listUsedAssetLiterals() -> [String] {
    let enumerator = FileManager.default.enumerator(atPath:sourcePath)
    print(sourcePath)
    
    #if swift(>=4.1)
        return elementsInEnumerator(enumerator)
            .filter { $0.hasSuffix(".m") || $0.hasSuffix(".swift") || $0.hasSuffix(".xib") || $0.hasSuffix(".storyboard") }    // Only Swift and Obj-C files
            .map { "\(sourcePath)/\($0)" }                              // Build file paths
            .map { try? String(contentsOfFile: $0, encoding: .utf8)}    // Get file contents
            .compactMap{$0}
            .compactMap{$0}                                             // Remove nil entries
            .map(localizedStrings)                                      // Find localizedStrings ocurrences
            .flatMap{$0}                                                // Flatten
    #else
        return elementsInEnumerator(enumerator)
            .filter { $0.hasSuffix(".m") || $0.hasSuffix(".swift") || $0.hasSuffix(".xib") || $0.hasSuffix(".storyboard") }    // Only Swift and Obj-C files
            .map { "\(sourcePath)/\($0)" }                              // Build file paths
            .map { try? String(contentsOfFile: $0, encoding: .utf8)}    // Get file contents
            .flatMap{$0}
            .flatMap{$0}                                                // Remove nil entries
            .map(localizedStrings)                                      // Find localizedStrings ocurrences
            .flatMap{$0}                                                // Flatten
    #endif
}


// MARK: - Begining of script
let assets = Set(listAssets())
let used = Set(listUsedAssetLiterals() + ignoredUnusedNames)


// Generate Warnings for Unused Assets
let unused = assets.subtracting(used)
unused.forEach { print("\(assetCatalogAbsolutePath):: warning: [Asset Unused] \($0)") }


// Generate Error for broken Assets
let broken = used.subtracting(assets)
broken.forEach { print("\(assetCatalogAbsolutePath):: error: [Asset Missing] \($0)") }

if broken.count > 0 {
    exit(1)
}
