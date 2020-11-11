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
    var driver: CQueue!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.panel = FileOpener()
        self.driver = CQueue()
    }
    
    override func keyDown(with event: NSEvent) {
        self.driver.add(item: event)
        self.driver.process() { (commandType, cmd) -> () in
            commandView.stringValue = ":\(cmd)"

            switch commandType {
            case .openFile:
                self.panel.runModal() { (fileUrl) -> () in
                    self.pdfView.document = PDFDocument(url: fileUrl)
                }
            case .standstill:
                break
            }
        }
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}

