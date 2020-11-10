//
//  CQueue.swift
//  VimPdf
//
//  Created by phatle on 11/10/20.
//

import Foundation

class CQueue {
    var queue: [String]
    enum Command {
        case openFile
    }
    
    init() {
        self.queue = []
    }
    
    func add(item: String) {
        self.queue.append(item)
    }
    
    func process(callback: (Command) -> ()) {
        switch self.queue.joined() {
        case "o":
            callback(.openFile)
        default:
            break
        }
    }
}
