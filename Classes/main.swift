#!/usr/bin/env xcrun --sdk macosx swift

import Foundation

// Configure me \o/
var sourcePathOption:String?
var ignoredUnusedNames = [String]()
var catalogPath: String?

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

/// Attempt to fetch source path from run script arguments
// command line arguments passed as "source:/path/to"
struct CommandLineArg {
    let arg: String
    let value: String?
}

let commandLineArguments = CommandLine.arguments.map { clArg -> CommandLineArg in
    let splitArgs = clArg.split(separator: ":")
    let value = splitArgs.indices.contains(1) ? String(splitArgs[1]) : nil
    return CommandLineArg(arg: String(splitArgs[0]), value: value)
}

for arg in commandLineArguments {
    switch arg.arg {
    case "source":
        if let sourcePath = arg.value, sourcePathOption == nil {
            sourcePathOption = sourcePath
        }
    case "catalog":
        if let catelog = arg.value, catalogPath == nil {
            catalogPath = catelog
        }
    case "ignore":
        if let ignoreAssetsNames = arg.value, ignoredUnusedNames.isEmpty {
            ignoredUnusedNames = ignoreAssetsNames.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        }
    default:
        break
    }
}

guard let sourcePath = sourcePathOption else {
    print("AssetChecker:: error: Source path was missing!")
    exit(0)
}

private func elementsInEnumerator(_ enumerator: FileManager.DirectoryEnumerator?) -> [String] {
    var elements = [String]()
    while let e = enumerator?.nextObject() as? String {
        elements.append(e)
    }
    return elements
}

/// Search for asset catalogs within the source path

let assetCatalogPaths: [String] = {
    if let providedCatalog = catalogPath {
        return [providedCatalog]
    } else {
        // detect automatically
        return elementsInEnumerator(FileManager.default.enumerator(atPath: sourcePath)).filter { $0.hasSuffix(".xcassets") }
    }
}()

print("Searching sources in \(sourcePath) for assets in \(assetCatalogPaths)")

/// List assets in found asset catalogs
private func listAssets() -> [(asset: String, catalog: String)] {
    
    return assetCatalogPaths.flatMap { (catalog) -> [(asset: String, catalog: String)] in
        
        let extensionName = "imageset"
        let enumerator = FileManager.default.enumerator(atPath: catalog)
        return elementsInEnumerator(enumerator)
            .filter { $0.hasSuffix(extensionName) }                             // Is Asset
            .map { $0.replacingOccurrences(of: ".\(extensionName)", with: "") } // Remove extension
            .map { $0.components(separatedBy: "/").last ?? $0 }                 // Remove folder path
            .map { (asset: $0,catalog: catalog)}
    }
}

/// List Assets used in the codebase
private func listUsedAssetLiterals() -> [String: [String]]  {
    let enumerator = FileManager.default.enumerator(atPath:sourcePath)
    
    var assetUsageMap: [String: [String]] = [:]
    
    // Only Swift and Obj-C files
    let files = elementsInEnumerator(enumerator)
        .filter { $0.hasSuffix(".m") || $0.hasSuffix(".swift") || $0.hasSuffix(".xib") || $0.hasSuffix(".storyboard") }
    
    /// Find sources of assets within the contents of a file
    func localizedStrings(inStringFile: String) -> [String] {
        var assetStringReferences = [String]()
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
                    assetStringReferences.append(value)
                }
            }
        }
        return assetStringReferences
    }
    
    for filename in files {
        // Build file paths
        let filepath = "\(sourcePath)/\(filename)"
        
        // Get file contents
        if let fileContents = try? String(contentsOfFile: filepath, encoding: .utf8) {
            // Find occurrences of asset names
            let references = localizedStrings(inStringFile: fileContents)
            
            // assemble the map
            for asset in references {
                let updatedReferences = assetUsageMap[asset] ?? []
                assetUsageMap[asset] = updatedReferences + [filename]
            }
        }
    }
    
    return assetUsageMap
}


// MARK: - Begining of script

let availableAssets = listAssets()
let availableAssetNames = Set(availableAssets.map{$0.asset} )
let usedAssets = listUsedAssetLiterals()
let usedAssetNames = Set(usedAssets.keys + ignoredUnusedNames)

// Generate Warnings for Unused Assets
let unused = availableAssets.filter({ (asset, catalog) -> Bool in !usedAssetNames.contains(asset) && !ignoredUnusedNames.contains(asset) })
unused.forEach { print("\($1):: warning: [Asset Unused] \($0)") }

// Generate Error for broken Assets
let broken = usedAssets.filter { (assetName, references) -> Bool in !availableAssetNames.contains(assetName) }
broken.forEach { print("\($1.first ?? $0):: error: [Asset Missing] \($0)") }

if broken.count > 0 {
    exit(1)
}
