//
//  ShellExecutor.swift
//  XcodeHelper
//
//  Created by Tian on 2020/11/12.
//

import Cocoa


typealias ExecutorBlock = (String?) -> ()

class ShellExecutor {

    @discardableResult
    class func execute(_ command: String) -> (Int32, String?) {
        let task = Process()
        task.launchPath = "/bin/bash"
        task.arguments = ["-c", command]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        
        task.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)
        
        task.waitUntilExit()
        
        return (task.terminationStatus, output)
    }
    
    @discardableResult
    class func execute(_ command: String, completion: ExecutorBlock? = nil) -> (Int32, String?) {
        let (ret, output) = execute(command)
        if let output = output {
            if let finished = completion {
                finished(output)
            }
        }
        return (ret, output)
    }
}

