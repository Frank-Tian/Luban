//
//  FileReader.swift
//  XcodeHelper
//
//  Created by Tian on 2020/11/16.
//

import Foundation

class FileReader: NSObject {
    static let shared = FileReader()
    let fileManager: FileManager
    
    private override init() {
        fileManager = FileManager.default
    }
    
    func readFile(path: String) -> String? {
        let read = fileManager.isReadableFile(atPath: path)
        
        guard read else {
            Logger.echo("File is Unreadable, path: \(path)", type: .error)
            return nil
        }
        
        let data = fileManager.contents(atPath: path)
        if let d = data {
            let str = String(data: d, encoding: .utf8)
            return str
        } else {
            Logger.echo("File is Empty, path: \(path)", type: .error)
        }
        
        return nil
    }
    
}
