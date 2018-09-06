#!/usr/bin/env xcrun --sdk macosx swift

import Foundation

// Configure me \o/
var sourcePathOption:String? = nil
let ignoredUnusedNames = [String]()

for (index, arg) in CommandLine.arguments.enumerated() {
    switch index {
    case 1:
        sourcePathOption = arg
    default:
        break
    }
}

guard let sourcePath = sourcePathOption else {
    print("AssetChecker:: error: Source path was missing!")
    exit(0)
}

func elementsInEnumerator(_ enumerator: FileManager.DirectoryEnumerator?) -> [String] {
    var elements = [String]()
    while let e = enumerator?.nextObject() as? String {
        elements.append(e)
    }
    return elements
}

// MARK: - Search for asset catalogs
let assetCatalogPaths = elementsInEnumerator(FileManager.default.enumerator(atPath: sourcePath)).filter { $0.hasSuffix(".xcassets") }

print("Searching sources in \(sourcePath) for assets in \(assetCatalogPaths)")

// MARK: - List Assets

func listAssets() -> [(asset: String, catalog: String)] {
    
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


// MARK: - List Used Assets in the codebase

func localizedStrings(inStringFile: String) -> [String] {
    var localizedStrings = [String]()
    let patterns = [
        "#imageLiteral\\(resourceName: \"([\\w-]+)\"\\)", // Image Literal
        "UIImage\\(named: \"(\\w+)\"\\)", // Default UIImage call
        "\\<image name=\"([\\w-]+)\".*", // Storyboard resources
        "R.image.([\\w-]+)\\(\\)" //R.swift support
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

func listUsedAssetLiterals() -> [String: [String]]  {
    let enumerator = FileManager.default.enumerator(atPath:sourcePath)
    
    var assetUsageMap: [String: [String]] = [:]
    
    let files = elementsInEnumerator(enumerator)
        .filter { $0.hasSuffix(".m") || $0.hasSuffix(".swift") || $0.hasSuffix(".xib") || $0.hasSuffix(".storyboard") }    // Only Swift and Obj-C files
    
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
// (name, catalog)
let unused = availableAssets.filter({ (asset, catalog) -> Bool in !usedAssetNames.contains(asset) })
unused.forEach { print("\($1):: warning: [Asset Unused] \($0)") }
// unused asset <name> found in <catalog>

// Generate Error for broken Assets
// (name, [fileReferences])
let broken = usedAssets.filter { (assetName, references) -> Bool in
    !availableAssetNames.contains(assetName)
}

broken.forEach { print("\($1.first ?? $0):: error: [Asset Missing] \($0)") }
// asset <name> used in file <filename> wasn't found!

if broken.count > 0 {
    exit(1)
}
