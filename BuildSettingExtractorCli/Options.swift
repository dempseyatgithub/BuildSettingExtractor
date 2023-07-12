//
//  Options.swift
//  BuildSettingExtractorCli
//
//  Created by ByteDance on 2023/7/11.
//  Copyright © 2023 Tapas Software. All rights reserved.
//

import Foundation

struct Options {
    var input: String = ""
    var output: String = ""

    static func printUsage() {
        print("Extract build settings from xcodeproj to xconfig")
        print("Args:")
        print("-x, --xcodeproj: Path to xcodeproj")
        print("-o, --ouput_dir: Output dir, should already exists")
    }

    static func verify(options: Self) -> Bool {
        guard !options.input.isEmpty else {
            print("xcodeproj is empty!")
            return false
        }
        guard options.input.hasSuffix(".xcodeproj"),
              FileManager.default.fileExists(atPath: options.input) else {
            print("Cannot find xcodeproj!")
            return false
        }
        guard !options.output.isEmpty else {
            print("output dir is empty")
            return false
        }
        return true
    }

    static func parse(_ inputs: ArraySlice<String>) -> Options {
        var index = inputs.startIndex

        func readPath(after index: inout Array.Index) -> String {
            guard index + 1 < inputs.endIndex else {
                print("Miss value after \(inputs[index])")
                exit(1)
            }
            defer {
                index += 1
            }
            return inputs[index + 1]
        }

        var options = Options()
        while index < inputs.endIndex {
            defer {
                index += 1
            }
            switch inputs[index] {
            case "-x", "--xcodeproj":
                options.input = readPath(after: &index)
            case "-o", "--ouput_dir":
                options.output = readPath(after: &index)
            case "-h", "--help":
                printUsage()
                exit(0)
            case "-v", "--version":
                print("1.0.0")
                exit(0)
            default:
                print("Not support args: \(inputs[index])")
                exit(1)
            }
        }

        if !verify(options: options) {
            exit(1)
        }
        return options
    }
}
