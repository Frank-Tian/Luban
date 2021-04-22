//
//  BrowserHelper.swift
//  XcodeHelper
//
//  Created by Tian on 2020/11/14.
//

import Foundation

enum InfoKey: String {
    case buildVersion   = "CFBundleVersion"
    case identifier     = "CFBundleIdentifier"
    case shortVersion   = "CFBundleShortVersionString"
    case displayName    = "CFBundleDisplayName"
}

class ShellHelper {
    static let errorValue = "Error Reading File: /"

    @discardableResult
    class func openBrowser(_ url: String, completion: ExecutorBlock? = nil) -> (Int32, String?) {
        let url = url.contains("http") ? url : "http://\(url)"
        let cmd = "open \(url)"
        let (ret, output) = ShellExecutor.execute(cmd) { (output) in
            if completion != nil {
                completion!(output)
            }
        }
        return (ret, output)
    }
    
    @discardableResult
    class func getProjectRoot(completion: ExecutorBlock? = nil) -> String? {
        let _cmd = "echo ${PROJECT_DIR}"
        let (_, output) = ShellExecutor.execute(_cmd) { (output) in
            if completion != nil {
                completion!(output)
            }
        }
        return output?.replacingOccurrences(of: "\n", with: "")
    }
    
    @discardableResult
    class func getFlutterRoot(completion: ExecutorBlock? = nil) -> String? {
        let _cmd = "echo ${FLUTTER_APPLICATION_PATH}"
        let (_, output) = ShellExecutor.execute(_cmd) { (output) in
            if completion != nil {
                completion!(output)
            }
        }
        return output?.replacingOccurrences(of: "\n", with: "")
    }
    
    @discardableResult
    class func infoForKey(_ key: InfoKey, completion: ExecutorBlock? = nil) -> String? {
        let _cmd = "/usr/libexec/PlistBuddy -c \"Print :\(key.rawValue)\" \"${TARGET_BUILD_DIR}/${INFOPLIST_PATH}\""
        let (_, output) = ShellExecutor.execute(_cmd) { (output) in
            if completion != nil {
                completion!(output)
            }
        }
        return output?.trimmingCharacters(in: ["\n"]).replacingOccurrences(of: errorValue, with: "")
    }
    
    class func getBuildConfig() -> String? {
        let _cmd = "echo ${CONFIGURATION}"
        let (_, output) = ShellExecutor.execute(_cmd) { (output) in
        }
        return  output?.trimmingCharacters(in: ["\n"])
    }
}
