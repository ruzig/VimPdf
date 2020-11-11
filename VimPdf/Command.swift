//
//  Command.swift
//  VimPdf
//
//  Created by phatle on 11/11/20.
//

import Foundation

enum CommandType {
    case openFile, standstill, firstPage, lastPage, goto
}

struct Command {
    var message: String
    var type: CommandType
    var metadata: [String: Any]?
}
