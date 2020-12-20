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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.panel = FileOpener()
        self.driver = CQueue()
        
        DocModel(context: self.context).cleanUp()

        self.pdfView.open(doc: DocModel(context: self.context).last())
    }
    
    func openFile() {
        self.panel.runModal() { (fileUrl) -> () in
            self.pdfView.openFile(url: fileUrl)
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
                self.pdfView.saveMark(character: cmd.metadata!["character"] as! String)
            case .loadMark:
                self.pdfView.loadMark(character: cmd.metadata!["character"] as! String)
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
            case .list:
                commandView.stringValue = "Recent documents:" + "\n\(listRecentDocuments())" +
                    "\n\(cmd.message)"
            case .openRecentDoc:
                let docs = DocModel(context: self.context).top50()
                let count = docs.count
                let num = count - (cmd.metadata!["order"]! as! Int)


                if (num >= 0 && num < count) {
                    let doc = docs[num]
                    self.pdfView.open(doc: doc)
                }

            }
            try! self.context.save()
        }
    }
    
    func listRecentDocuments() -> String {
        let docs = DocModel(context: self.context).top50()
        let names = docs.compactMap { doc in
            return (doc.fileUrl?.lastPathComponent ?? nil)
        }
        let count = names.count
        let result = names.enumerated().map { (index, name) in
            
            return "\(count - index). \(name)"
        }
        return result.joined(separator: "\n")
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}

