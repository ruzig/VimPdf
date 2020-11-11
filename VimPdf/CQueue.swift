//
//  CQueue.swift
//  VimPdf
//
//  Created by phatle on 11/10/20.
//

import Foundation
import Cocoa

class CQueue {
    var queue: [NSEvent]
    enum Command {
        case openFile, standstill
    }
    
    init() {
        self.queue = []
    }
    
    func add(item: NSEvent) {
        self.queue.append(item)
    }
    
    func computeEvent() {
        struct Keycode {
            static let escape                    : UInt16 = 0x35
        }
        if self.queue.last?.keyCode == Keycode.escape {
            self.queue.removeAll()
        }
    }
    
    func toCommand() -> String {
        if self.queue.count == 0 {
            return "`Press ?` is your friend!"
        }
        return self.queue.map { (e) -> String in
            e.characters!
        }.joined();
    }
    
    func process(callback: (Command, String) -> ()) {
        computeEvent()
        let cmd = toCommand()
        switch cmd {
        case "o":
            self.queue.removeAll()
            callback(.openFile, toCommand())
        default:
            callback(.standstill, cmd)
        }
    }
}
