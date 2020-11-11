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
        self.driver.process() { (cmd) -> () in
            commandView.stringValue = ":\(cmd.message)"

            switch cmd.type {
            case .openFile:
                self.panel.runModal() { (fileUrl) -> () in
                    self.pdfView.document = PDFDocument(url: fileUrl)
                }
            case .firstPage:
                self.pdfView.goToFirstPage(nil)
            case .lastPage:
                self.pdfView.goToLastPage(nil)
            case .standstill:
                break
            case .goto:
                let page = self.pdfView.document?.page(at: cmd.metadata!["pageNum"] as! Int)
                if (page != nil) {
                    self.pdfView.go(to: page!)
                }
            }
        }
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}

