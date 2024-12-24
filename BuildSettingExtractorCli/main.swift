//
//  main.swift
//  BuildSettingExtractorCli
//
//  Created by ByteDance on 2023/7/11.
//  Copyright © 2023 Tapas Software. All rights reserved.
//

import Foundation


func main() throws {
    guard CommandLine.arguments.count > 1 else {
        Options.printUsage()
        exit(0)
    }
    
    let options = Options.parse(CommandLine.arguments[1...])

    let extractor = BuildSettingExtractor()
    _ = try extractor.extractBuildSettings(fromProject: URL(filePath: options.input))
    try extractor.writeConfigFiles(toDestinationFolder: URL(filePath: options.output))
}

do {
    try main()
} catch {
    print(error)
}
