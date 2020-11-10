//
//  FileOpener.swift
//  VimPdf
//
//  Created by phatle on 11/10/20.
//

import Cocoa

class FileOpener {
    var panel: NSOpenPanel
    init() {
        self.panel = NSOpenPanel()
        self.panel.title                   = "Open the world!";
        self.panel.showsResizeIndicator    = true;
        self.panel.showsHiddenFiles        = false;
        self.panel.allowsMultipleSelection = false;
        self.panel.canChooseDirectories = false;
        self.panel.allowedFileTypes = ["pdf"]
    }
    
    func runModal(callback: (URL) -> ()) {
        if (self.panel.runModal() ==  NSApplication.ModalResponse.OK) {
            let result = self.panel.url // Pathname of the file
            
            if (result != nil) {
                callback(result!)
            }
        } else {
            // User clicked on "Cancel"
            return
        }
    }
}
