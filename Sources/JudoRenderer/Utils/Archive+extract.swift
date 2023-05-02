// Copyright (c) 2023-present, Rover Labs, Inc. All rights reserved.
// You are hereby granted a non-exclusive, worldwide, royalty-free license to use,
// copy, modify, and distribute this software in source code or binary form for use
// in connection with the web services and APIs provided by Rover.
//
// This copyright notice shall be included in all copies or substantial portions of
// the software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
// IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import Foundation
import ZIPFoundation
import CryptoKit
import CoreText
import JudoModel
import XCAssetsKit

extension Archive {
    /// Extract the entire ZIP Entry (assuming it is a File entry) into a single buffer.
    func extractEntire(entry: Entry) throws -> Data {
        var buffer = Data(count: Int(entry.uncompressedSize))
        var position = 0

        // the CRC32 check is extremely slow in debug builds, so skip it.
#if DEBUG
        let skipCRC32 = true
#else
        let skipCRC32 = false
#endif

        // despite the closure, this is not asynchronous.
        let _ = try self.extract(entry, skipCRC32: skipCRC32) { chunk in
            let endPos = Swift.min(position + chunk.count, Int(entry.uncompressedSize))
            let targetRange: Range<Data.Index> = position..<endPos
            if targetRange.count > 0 {
                buffer[targetRange] = chunk
            }
            position = endPos
        }
        return buffer
    }

    func extractXCAssets(_ folderName: String = "Assets.xcassets") -> XCAssetCatalog {
        let xcassetEntries = filter({ $0.path.hasPrefix(folderName + "/") })
        if xcassetEntries.isEmpty {
            return XCAssetCatalog()
        }

        do {
            let temporaryDirectoryURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".bundle", isDirectory: true).standardized
            try FileManager.default.createDirectory(at: temporaryDirectoryURL, withIntermediateDirectories: true)
            for entry in xcassetEntries {
                _ = try extract(entry, to: temporaryDirectoryURL.appendingPathComponent("/" + entry.path))
            }
            let xcassetsPath = temporaryDirectoryURL.appendingPathComponent(folderName)
            return XCAssetCatalog(at: xcassetsPath)
        } catch {
            assertionFailure("Missing Assets Catalog")
            return XCAssetCatalog()
        }
    }

    func extractFonts() throws -> Set<FontValue> {
        let entriesByPath: [String: Entry] = reduce(into: [:]) { result, entry in
            result[entry.path] = entry
        }

        let fontsEntries = entriesByPath.filter { (path, entry) in
            (path.starts(with: "fonts/") || path.starts(with: "/fonts/")) && entry.type == .file
        }

        return try fontsEntries.reduce(into: []) { result, element in
            guard element.value.type == .file else {
                throw CocoaError(.fileReadUnknown)
            }

            let fileURL = URL(fileURLWithPath: element.key)
            let fontData = try extractEntire(entry: element.value)
            let fontValue = try FontValue(data: fontData, fileExtension: fileURL.pathExtension)
            result.insert(fontValue)
        }
    }


    func extractLocalizations() throws -> DocumentLocalizations {
        let entriesByPath: [String: Entry] = reduce(into: [:]) { result, entry in
            result[entry.path] = entry
        }

        let stringsTableEntries = entriesByPath.filter { (path, entry) in
            (path.starts(with: "localization/") || path.starts(with: "/localization/")) && entry.type == .file && (path as NSString).pathExtension == "json"
        }

        let decoder = JSONDecoder()
        let entries: DocumentLocalizations.Entries = try stringsTableEntries.reduce(into: [:]) { result, element in
            let localeIdentifier = DocumentLocalizations.LocaleIdentifier((element.key as NSString).lastPathComponent)
            let table = try decoder.decode(DocumentLocalizations.StringsTable.self, from: try extractEntire(entry: element.value))

            result[localeIdentifier] = table
        }
        return DocumentLocalizations(entries: entries)
    }
    
}
