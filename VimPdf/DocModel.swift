//
//  DocModel.swift
//  VimPdf
//
//  Created by phatle on 11/15/20.
//

import Foundation
import CoreData
import PDFKit

class DocModel {
    var context: NSManagedObjectContext
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    func create(fileUrl: URL) -> Doc{
        let request = Doc.fetchRequest() as NSFetchRequest<Doc>
        request.predicate = NSPredicate(format: "fileUrl == %@", fileUrl as CVarArg)
        let items = try! context.fetch(request)
        var result: Doc
        if (items.last == nil) {
            let newDoc = Doc(context: self.context)
            newDoc.fileUrl = fileUrl
            newDoc.openedAt = Date()
            result = newDoc
        } else {
            let doc = items.last!
            doc.openedAt = Date()
            result = doc
        }
        
        try! self.context.save()
        return result
    }
    
    func last() -> Doc? {
        let request = Doc.fetchRequest() as NSFetchRequest<Doc>
        request.sortDescriptors = [NSSortDescriptor.init(key: "openedAt", ascending: true)]
        let items = try! context.fetch(request)
        return items.last
    }
    
    func top50() -> [Doc] {
        let request = Doc.fetchRequest() as NSFetchRequest<Doc>
        request.sortDescriptors = [NSSortDescriptor.init(key: "openedAt", ascending: true)]
        request.fetchLimit = 50
        let items = try! context.fetch(request)
        return items
    }
    
    func cleanUp() {
        removeInvalid()
        removeExpired()
    }
    
    func removeInvalid() {
        let request = Doc.fetchRequest() as NSFetchRequest<Doc>
        request.sortDescriptors = [NSSortDescriptor.init(key: "openedAt", ascending: true)]
        let items = try! context.fetch(request)
        items.forEach { doc in
            let url = FilePermission.loadBookmark(doc: doc)
            
            if url != nil {
                _ = url!.startAccessingSecurityScopedResource()
                let valid = PDFDocument(url: url!)
                if valid == nil {
                    context.delete(doc)
                }
                url!.stopAccessingSecurityScopedResource()
            }

        }
    }
    
    func removeExpired() {
        let request = Doc.fetchRequest() as NSFetchRequest<Doc>
        request.sortDescriptors = [NSSortDescriptor.init(key: "openedAt", ascending: true)]
        let items = try! context.fetch(request)
        if items.count > 50 {
            let expires = items.suffix(from: 50)
            expires.forEach { (doc) in
                context.delete(doc)
            }
        }
    }
}
