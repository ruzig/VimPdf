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
    var marks: [String: Int]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.panel = FileOpener()
        self.driver = CQueue()
        self.marks = ["": 0]
    }
    
    func saveMark(character: String) {
        self.marks[character] = (self.pdfView.currentPage?.pageRef!.pageNumber)! - 1
    }
    
    func loadMark(character: String) {
        let pageNumber = self.marks[character]
        if pageNumber != nil {
            let page = self.pdfView.document?.page(at: pageNumber!)
            if (page != nil) {
                self.pdfView.go(to: page!)
            }
        }
    }
    
    func down() {
        for _ in 0..<30 {
            self.pdfView.scrollLineUp(nil)
        }
    }
    
    func up() {
        for _ in 0..<30 {
            self.pdfView.scrollLineDown(nil)
        }
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
            case .mark:
                saveMark(character: cmd.metadata!["character"] as! String)
            case .loadMark:
                loadMark(character: cmd.metadata!["character"] as! String)
            case .down:
                down()
            case .up:
                up()
            }
        }
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}

