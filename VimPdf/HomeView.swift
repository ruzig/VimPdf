//
//  HomeView.swift
//  VimPdf
//
//  Created by phatle on 12/9/20.
//

import Foundation
import PDFKit

class HomeView: PDFView {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        registerForDraggedTypes([NSPasteboard.PasteboardType.pdf])
    }
    
    override func draggingEnded(_ sender: NSDraggingInfo) {
        let pasteBoard = sender.draggingPasteboard

        Swift.print(sender)
        
        
        if let urls = pasteBoard.readObjects(forClasses: [NSURL.self]) as? [URL]{
            self.document = PDFDocument(url: urls.last!)
        }
    }
}
