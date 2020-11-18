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
    let context = (NSApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var panel: FileOpener!
    var driver: CQueue!
    var marks: [String: Int]!
    var currentDoc: Doc!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.panel = FileOpener()
        self.driver = CQueue()
        self.marks = ["": 0]
        
        loadLastRead()
        loadMarks()
        self.pdfView.autoScales = true
    }
    func loadMarks() {
        if (self.currentDoc.marks != nil) {
            self.marks = try! JSONDecoder().decode([String: Int].self, from: self.currentDoc.marks!)
        }
    }
    
    func saveMark(character: String) {
        self.marks[character] = (self.pdfView.currentPage?.pageRef!.pageNumber)! - 1
        self.currentDoc.marks = try! JSONEncoder().encode(self.marks)
        try! self.context.save()
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
    
    func openFile() {
        self.panel.runModal() { (fileUrl) -> () in
            let doc = DocModel(context: self.context).create(fileUrl: fileUrl)
            FilePermission.saveBookmark(doc: doc)
            self.pdfView.document = PDFDocument(url:fileUrl)
        }
    }
    
    func loadLastRead() {
        self.currentDoc = DocModel(context: self.context).last()
        let url = FilePermission.loadBookmark(doc: self.currentDoc)
        
        if url != nil {
            _ = url!.startAccessingSecurityScopedResource()
            self.pdfView.document = PDFDocument(url: url!)
            

            DispatchQueue.main.async  {
                let lastReadPage = self.currentDoc!.lastPage
                if let page = self.pdfView.document?.page(at: Int(lastReadPage)) {
                    self.pdfView.go(to: page)
                    NotificationCenter.default.addObserver(self, selector: #selector(self.saveLastReadPage),name: .PDFViewPageChanged, object: nil)
                }
            }
            
            url!.stopAccessingSecurityScopedResource()
        }
    }
    
    @objc private func saveLastReadPage(notification: Notification) {
        let pdfView = notification.object as! PDFView
        let page = pdfView.currentDestination?.page?.pageRef?.pageNumber
        self.currentDoc.lastPage = Int64(page!)
        try! self.context.save()
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

