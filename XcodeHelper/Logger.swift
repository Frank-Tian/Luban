//
//  Logger.swift
//  XcodeHelper
//
//  Created by Tian on 2020/11/13.
//

import Foundation

enum LogType {
    case error
    case warning
    case info
    case debug
}

class Logger {
    static let prefixError = "❌XcodeHelper❌"
    static let prefixWarning = "⚠️XcodeHelper⚠️"
    static let prefixInfo = "🔆XcodeHelper🔆"
    static let prefixDebug = "🤖XcodeHelper🤖"
    
    class func echo(_ message: String?, type: LogType? = .info) -> Void {
        guard let content = message else {
            return
        }
        
        switch type {
        case .debug:
            print("\(prefixDebug): \(content)")
        case .info:
            print("\(prefixInfo): \(content)")
        case .warning:
            print("\(prefixWarning): \(content)")
        case .error:
            print("\(prefixError): \(content)")
        default:
            ()
        }
    }
}
