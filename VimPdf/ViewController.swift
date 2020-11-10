//
//  ViewController.swift
//  VimPdf
//
//  Created by phatle on 11/10/20.
//

import Cocoa
import PDFKit

class ViewController: NSViewController {
    
    @IBOutlet weak var commandView: NSTextFieldCell!
    @IBOutlet weak var pdfView: PDFView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) {
            self.flagsChanged(with: $0)
            return $0
        }
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) {
            self.keyDown(with: $0)
            return $0
        }
    }
    
    override func keyDown(with event: NSEvent) {
        switch event.characters {
        case "f":
            print("open file")
            openFile()
        default:
            break
        }
        commandView.stringValue = ":" + (event.characters
                                                ?? "")
    }
    
    func openFile() {
        let dialog = NSOpenPanel();
        
        dialog.title                   = "Choose a file| Our Code World";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.allowsMultipleSelection = false;
        dialog.canChooseDirectories = false;
        
        if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
            let result = dialog.url // Pathname of the file
            
            if (result != nil) {
                let path: String = result!.path
                
                print(path)
                self.pdfView.document = PDFDocument(url: result!)
                
                // path contains the file path e.g
                // /Users/ourcodeworld/Desktop/file.txt
            }
        } else {
            // User clicked on "Cancel"
            return
        }
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}

