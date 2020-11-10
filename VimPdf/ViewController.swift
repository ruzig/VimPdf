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
    
    var panel: FileOpener!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.panel = FileOpener()
    }
    
    override func keyDown(with event: NSEvent) {
        switch event.characters {
        case "o":
            print("open file")
            self.panel.runModal() { (fileUrl) -> () in
                self.pdfView.document = PDFDocument(url: fileUrl)
            }
            commandView.stringValue = ":`Press ?` is your friend!"
        default:
            break
        }
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}

