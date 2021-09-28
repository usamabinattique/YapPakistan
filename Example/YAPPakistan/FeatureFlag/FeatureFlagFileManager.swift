//
//  FeatureFlagFileManager.swift
//  YAPPakistan_Example
//
//  Created by Umer on 24/09/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation

protocol FeatureFlagReadableDatabase {
    func readFeatureFlags() -> [FeatureFlag]?
}
protocol FeatureFlagWritableDatabase {
    func writeFeatureFlags(featureFlags: [FeatureFlag])
}

typealias FeatureFlagDatabase = FeatureFlagReadableDatabase & FeatureFlagWritableDatabase

struct FeatureFlagFileManager {
    private static let folderName = "Feature"
    private static let fileName = "Flag"

    public init() {
    }

    private var manager = FileManager.default

    func fileHandle() throws -> URL {
        let rootFolderURL = try manager.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        )
        let nestedFolderURL = rootFolderURL.appendingPathComponent(FeatureFlagFileManager.folderName)
        do {
            if !manager.fileExists(atPath: nestedFolderURL.relativePath) {
                try manager.createDirectory(
                    at: nestedFolderURL,
                    withIntermediateDirectories: false,
                    attributes: nil
                )
            }
        }
        catch CocoaError.fileWriteFileExists {
            // Folder already existed
        }
        catch {
            throw error
        }

        let fileURL = nestedFolderURL.appendingPathComponent(FeatureFlagFileManager.fileName)
        return fileURL
    }

    func write<T: Encodable>(
        _ object: T,
        encodedUsing encoder: JSONEncoder = .init()
    ) throws {
        let data = try encoder.encode(object)
        try data.write(to: fileHandle())
    }

    func read<T: Decodable>(decodedUsing decoder: JSONDecoder = .init()) throws -> T {
        let data = try Data(contentsOf: fileHandle())
        return try decoder.decode(T.self, from: data)
    }
}

extension FeatureFlagFileManager: FeatureFlagDatabase {
    func readFeatureFlags() -> [FeatureFlag]? {
        do {
            let flags: [FeatureFlag] = try read()
            return flags
        }
        catch let ex {
            debugPrint(ex.localizedDescription)
        }
        return nil
    }

    func writeFeatureFlags(featureFlags: [FeatureFlag]) {
        do {
            try write(featureFlags)
        }
        catch let ex {
            debugPrint(ex.localizedDescription)
        }
    }

}
