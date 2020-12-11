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
    @IBOutlet weak var pdfView: HomeView!
    let context = (NSApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var panel: FileOpener!
    var driver: CQueue!
    var marks: [String: Int]!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.panel = FileOpener()
        self.driver = CQueue()
        

        self.pdfView.open(doc: DocModel(context: self.context).last())
        self.marks = self.pdfView.marks()
        
        
    }
    
    func saveMark(character: String) {
        if (self.pdfView.currentDoc != nil) {
            self.marks[character] = (self.pdfView.currentPage?.pageRef!.pageNumber)! - 1
            self.pdfView.currentDoc.marks = try! JSONEncoder().encode(self.marks)
            try! self.context.save()
        }
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
    
    func openFile() {
        self.panel.runModal() { (fileUrl) -> () in
            let doc = DocModel(context: self.context).create(fileUrl: fileUrl)
            FilePermission.saveBookmark(doc: doc)
            self.pdfView.open(doc: doc)
            self.marks = self.pdfView.marks()
        }
    }
    
    override func keyDown(with event: NSEvent) {
        self.driver.add(item: event)
        self.driver.process() { (cmd) -> () in
            commandView.stringValue = cmd.message

            switch cmd.type {
            case .openFile:
                openFile()
            case .firstPage:
                self.pdfView.goToFirstPage(nil)
            case .lastPage:
                self.pdfView.goToLastPage(nil)
            case .toggle:
                self.commandView.controlView?.isHidden = !self.commandView.controlView!.isHidden
                self.view.window?.titlebarAppearsTransparent = !(self.view.window?.titlebarAppearsTransparent ?? false)
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
                self.pdfView.down()
            case .up:
                self.pdfView.up()
            case .back:
                self.pdfView.goBack(nil)
            case .forward:
                self.pdfView.goForward(nil)
            case .help:
                break
            }
            try! self.context.save()
        }
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}

