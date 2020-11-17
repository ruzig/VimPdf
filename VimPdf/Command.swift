//
//  Command.swift
//  VimPdf
//
//  Created by phatle on 11/11/20.
//

import Foundation

enum CommandType {
    case openFile, standstill,
         firstPage, lastPage, goto,
         mark, loadMark,
         down, up,
         back, forward
         
}

struct Command {
    var message: String
    var type: CommandType
    var metadata: [String: Any]?
}
