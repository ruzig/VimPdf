//
//  HomeView.swift
//  VimPdf
//
//  Created by phatle on 12/9/20.
//

import Foundation
import PDFKit
import Cocoa

class HomeView: PDFView {
    
    var currentDocument: PDFDocument?
    var currentDoc: Doc!
    let context = (NSApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var marks: [String: Int]!

    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.autoScales = true
        self.backgroundColor = NSColor.white
        
        registerForDraggedTypes([NSPasteboard.PasteboardType.pdf])
        NotificationCenter.default.addObserver(self, selector: #selector(self.saveLastReadPage),name: .PDFViewPageChanged, object: nil)
    }
    
    @objc private func saveLastReadPage(notification: Notification) {
        if self.currentDoc != nil {
            self.currentDoc.lastPage = self.currentPageNumber()
        }
    }
    
    override func draggingEnded(_ sender: NSDraggingInfo) {
        let pasteBoard = sender.draggingPasteboard

        Swift.print(sender)
        
        
        if let urls = pasteBoard.readObjects(forClasses: [NSURL.self]) as? [URL]{
            self.openFile(url: urls.last!)
        }
    }
    
    func openFile(url: URL) {
        let doc = DocModel(context: self.context).create(fileUrl: url)
        FilePermission.saveBookmark(doc: doc)
        self.open(doc: doc)
    }
    
    func open(doc: Doc?) {
        if ((doc != nil) && (self.currentDoc?.id != doc?.id)) {
            self.currentDoc = doc

            let url = FilePermission.loadBookmark(doc: self.currentDoc!)
            
            if url != nil {
                _ = url!.startAccessingSecurityScopedResource()
                
                let lastReadPage = self.currentDoc!.lastPage
                self.currentDocument = PDFDocument(url: url!)
                self.document = self.currentDocument
                if let page = self.document?.page(at: Int(lastReadPage)) {
                    self.go(to: page)
                }
                loadMarks()
                url!.stopAccessingSecurityScopedResource()
            }
        }
    }
    
    func loadMarks() {
        if (self.currentDoc != nil && self.currentDoc.marks != nil) {
            self.marks = try! JSONDecoder().decode([String: Int].self, from: self.currentDoc.marks!)
        } else {
            self.marks = ["": 0]
        }
    }
    
    func saveMark(character: String) {
        if (self.currentDoc != nil) {
            self.marks[character] = (self.currentPage?.pageRef!.pageNumber)! - 1
            self.currentDoc.marks = try! JSONEncoder().encode(self.marks)
            try! self.context.save()
        }
    }
    
    func loadMark(character: String) {
        let pageNumber = self.marks[character]
        if pageNumber != nil {
            let page = self.document?.page(at: pageNumber!)
            if (page != nil) {
                self.go(to: page!)
            }
        }
    }
    
    func currentPageNumber() -> Int64 {
        return Int64(self.currentDestination?.page?.pageRef?.pageNumber ?? 0)
    }
    
    func down() {
        for _ in 0..<30 {
            self.scrollLineUp(nil)
        }
    }
    
    func up() {
        for _ in 0..<30 {
            self.scrollLineDown(nil)
        }
    }
}
