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
        case openFile, standstill
    }
    
    init() {
        self.queue = []
    }
    
    func add(item: String) {
        self.queue.append(item)
    }
    
    func toCommand() -> String {
        return self.queue.joined()
    }
    
    func process(callback: (Command, String) -> ()) {
        let cmd = toCommand()
        switch cmd {
        case "o":
            callback(.openFile, cmd)
        default:
            callback(.standstill, cmd)
        }
    }
}
