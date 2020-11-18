//
//  CQueue.swift
//  VimPdf
//
//  Created by phatle on 11/10/20.
//

import Foundation
import Cocoa

struct Keycode {
    static let escape                    : UInt16 = 0x35
    static let returnKey                 : UInt16 = 0x24
    static let enter                     : UInt16 = 0x4C
}

class CQueue {
    var queue: [NSEvent]
    
    init() {
        self.queue = []
    }
    
    func add(item: NSEvent) {
        self.queue.append(item)
    }
    
    func processEscape(callback: (Command) -> ()) {
        if self.queue.last?.keyCode == Keycode.escape {
            self.queue.removeAll()
            callback(Command(message: toMessage(), type: .standstill, metadata: nil))
        }
    }
    
    func processEnter(callback: (Command) -> ()) {
        if self.queue.last?.keyCode == Keycode.returnKey ||
            self.queue.last?.keyCode == Keycode.enter {
            self.queue.removeLast()
            let pageNum = Int(toMessage())
            self.queue.removeAll()
            if (pageNum != nil) {
                callback(Command(message: toMessage(), type: .goto, metadata: ["pageNum": pageNum!]))
            }
        }
    }
    
    func toMessage() -> String {
        if self.queue.count == 0 {
            return "`Press ?` is your friend!"
        }
        return self.queue.map { (e) -> String in
            e.characters!
        }.joined()
    }
    
    func processTextCommand(callback: (Command) -> ()) {
        if self.queue.count > 0 {
            let cmd = toMessage()
            switch cmd {
            case "o":
                self.queue.removeAll()
                callback(Command(message: ":" + toMessage(), type: CommandType.openFile, metadata: nil))
            case "gg":
                self.queue.removeAll()
                callback(Command(message: ":" + toMessage(), type: CommandType.firstPage, metadata: nil))
            case "G":
                self.queue.removeAll()
                callback(Command(message: ":" + toMessage(), type: CommandType.lastPage, metadata: nil))
            case "d", "j":
                self.queue.removeAll()
                callback(Command(message: ":" + toMessage(), type: CommandType.down, metadata: nil))
            case "u", "k":
                self.queue.removeAll()
                callback(Command(message: ":" + toMessage(), type: CommandType.up, metadata: nil))
            case "[", "b":
                self.queue.removeAll()
                callback(Command(message: ":" + toMessage(), type: CommandType.back, metadata: nil))
            case "]", "w":
                self.queue.removeAll()
                callback(Command(message: ":" + toMessage(), type: CommandType.forward, metadata: nil))
            case "?":
                self.queue.removeAll()
                let guide = """
                    o: Open File
                    d: Quarter page down
                    u: Quarter page up
                    gg: Go to First Page
                    G: Go to Last Page
                    [: Go back in history
                    ]: Go forward in history
                    m: Create a new mark, e.g: ma
                    ': Go to a mark, e.g: 'a
                    ⌘ +: Zoom in
                    ⌘ -: Zoom in
                    
                    Happy reading!
                """
                callback(Command(message: guide, type: CommandType.help, metadata: nil))
            default:
                callback(Command(message: cmd, type: CommandType.standstill, metadata: nil))
            }
        }
    }
    
    func processMark(callback: (Command) -> ()) {
        if self.queue.count == 2 && self.queue.first?.characters == "m" {
            let character = self.queue.last?.characters
            self.queue.removeAll()
            callback(Command(message: toMessage(), type: .mark, metadata: ["character": character!]))
            
        }
    }
    
    func processLoadMark(callback: (Command) -> ()) {
        if self.queue.count == 2 && self.queue.first?.characters == "'" {
            let character = self.queue.last?.characters
            self.queue.removeAll()
            callback(Command(message: toMessage(), type: .loadMark, metadata: ["character": character!]))
            
        }
    }
    
    func process(callback: (Command) -> ()) {
        if self.queue.count > 0 {
            processEscape(callback: callback)
            processEnter(callback: callback)
            processMark(callback: callback)
            processLoadMark(callback: callback)
            processTextCommand(callback: callback)
        }
    }
}
