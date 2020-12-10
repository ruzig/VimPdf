//
//  HomeView.swift
//  VimPdf
//
//  Created by phatle on 12/9/20.
//

import Foundation
import PDFKit

class HomeView: PDFView {
    
    var currentDocument: PDFDocument?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.autoScales = true
        
        registerForDraggedTypes([NSPasteboard.PasteboardType.pdf])
    }
    
    override func draggingEnded(_ sender: NSDraggingInfo) {
        let pasteBoard = sender.draggingPasteboard

        Swift.print(sender)
        
        
        if let urls = pasteBoard.readObjects(forClasses: [NSURL.self]) as? [URL]{
            self.document = PDFDocument(url: urls.last!)
        }
    }
    
    func loadLastRead(currentDoc: Doc?) {
        if (currentDoc != nil) {
            let url = FilePermission.loadBookmark(doc: currentDoc!)
            
            if url != nil {
                _ = url!.startAccessingSecurityScopedResource()
                
                let lastReadPage = currentDoc!.lastPage
                self.currentDocument = PDFDocument(url: url!)
                self.document = self.currentDocument
                if let page = self.document?.page(at: Int(lastReadPage)) {
                    self.go(to: page)
                }
                
                url!.stopAccessingSecurityScopedResource()
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
