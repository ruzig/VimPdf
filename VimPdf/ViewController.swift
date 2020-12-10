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
    var currentDoc: Doc!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.panel = FileOpener()
        self.driver = CQueue()
        self.marks = ["": 0]

        self.currentDoc = DocModel(context: self.context).last()
        self.pdfView.loadLastRead(currentDoc: self.currentDoc)
        loadMarks()
        NotificationCenter.default.addObserver(self, selector: #selector(self.saveLastReadPage),name: .PDFViewPageChanged, object: nil)
        let bundleURL = Bundle.main.bundleURL
        let parentVolumeURL = try! bundleURL.resourceValues(forKeys: [.volumeURLKey]).volume
        print(parentVolumeURL)
        print(bundleURL)
                
    }
    
    func loadMarks() {
        if (self.currentDoc != nil && self.currentDoc.marks != nil) {
            self.marks = try! JSONDecoder().decode([String: Int].self, from: self.currentDoc.marks!)
        }
    }
    
    func saveMark(character: String) {
        if (self.currentDoc != nil) {
            self.marks[character] = (self.pdfView.currentPage?.pageRef!.pageNumber)! - 1
            self.currentDoc.marks = try! JSONEncoder().encode(self.marks)
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
            self.currentDoc = DocModel(context: self.context).create(fileUrl: fileUrl)
            FilePermission.saveBookmark(doc: self.currentDoc)
            self.pdfView.loadLastRead(currentDoc: self.currentDoc)
            loadMarks()
        }
    }
    
    @objc private func saveLastReadPage(notification: Notification) {
        if self.currentDoc != nil {
            self.currentDoc.lastPage = self.pdfView.currentPageNumber()
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

