//
//  FilePermission.swift
//  VimPdf
//
//  Created by phatle on 11/16/20.
//

import Foundation
import AppKit

class FilePermission {
    static func saveBookmark(doc: Doc) {
        guard let url = doc.fileUrl else { return  }
        do {
            let bookmarkData = try url.bookmarkData(
                options: .minimalBookmark,
                includingResourceValuesForKeys: nil,
                relativeTo: nil
            )

            doc.bookmark = bookmarkData
        } catch {
            print("Failed to save bookmark data for \(url)", error)
        }
    }
    
    static func loadBookmark(doc: Doc) -> URL? {
        guard let data = doc.bookmark else { return nil }
        do {
            var isStale = false
            let url = try URL(
                resolvingBookmarkData: data,
                bookmarkDataIsStale: &isStale
            )
            if isStale {
                saveBookmark(doc: doc)
            }
            return url
        } catch {
            print("Error resolving bookmark:", error)
            return nil
        }
    }
    
    static func withPermission(url: URL, callback: () -> ()) {
        _ = url.startAccessingSecurityScopedResource()
        callback()
        url.stopAccessingSecurityScopedResource()
    }
}
