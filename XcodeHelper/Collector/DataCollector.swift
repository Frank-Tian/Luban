//
//  DataCollector.swift
//  XcodeHelper
//
//  Created by Tian on 2020/11/13.
//

import Foundation

///
/*
 
 $ sw_vers
 
 ProductName:    macOS
 ProductVersion: 11.0.1
 BuildVersion:   20B28
 
 $ system_profiler SPSoftwareDataType
 
 Software:

     System Software Overview:

       System Version: macOS 11.0.1 (20B28)
       Kernel Version: Darwin 20.1.0
       Boot Volume: Macintosh HD
       Boot Mode: Normal
       Computer Name: XXXX的MacBook Pro
       User Name: XXXX (xxx)
       Secure Virtual Memory: Enabled
       System Integrity Protection: Enabled
       Time since boot: 21 minutes
 */

class DataCollector {
    
    class func getAppInfo() -> AppInfo? {
        var app = AppInfo.init(JSON: [:])
        if Setting.pureFlutterIntegrate() {
            app?.appKey = Setting.appKeyInYaml()
        } else {
            app?.appKey = Setting.appKeyInSpec()
        }
        app?.appType = "iOS"
        app?.displayName = ShellHelper.infoForKey(.displayName)
        app?.appVersion = ShellHelper.infoForKey(.shortVersion)
        app?.buildNum = ShellHelper.infoForKey(.buildVersion)
        app?.bundleID = ShellHelper.infoForKey(.identifier)

        return app
    }
    
    class func getOSInfo() -> OSInfo? {
        var os = OSInfo.init(JSON: [:])
        func valueFor(_ keyValues: String) -> String {
            let value = keyValues.split(separator: ":").last?.trimmingCharacters(in: [" "])
            return value ?? "无"
        }
        
        let _cmd = "system_profiler SPSoftwareDataType"
        let (_, output) = ShellExecutor.execute(_cmd)
        if let info = output {
            let arr = info.split(separator: "\n")
            arr.forEach { (item) in
                switch (item) {
                /// 系统版本
                case let item where item.contains("System Version"):
                    let sys = valueFor(String(item)).split(separator: " ")
                    os?.osName = String(sys[0])
                    os?.productVersion = String(sys[1])
                    os?.buildVersion = String(sys[2]).trimmingCharacters(in: ["(",")"])
                /// 电脑名称
                case let item where item.contains("Computer Name"):
                    os?.computerName = valueFor(String(item))
                /// 用户名称
                case let item where item.contains("User Name"):
                    os?.userName = valueFor(String(item))
                default:
                    break
                }
            }
        }
        
        return os
    }
    
    class func getIDEInfo() -> IDEInfo? {
        var ide = IDEInfo.init(JSON: [:])
        let _cmd = "xcodebuild -version"
        let (_, output) = ShellExecutor.execute(_cmd)
        if let info = output {
            let arr = info.split(separator: "\n")
            ide?.version = String(arr.first ?? "NONE")
            ide?.buildVersion = String(arr.last?.split(separator: " ").last ?? "")
        }
        
        return ide
    }
    
    class func getScriptInfo() -> ScriptInfo? {
        return ScriptInfo.init(JSON: ["version": Setting.scriptVersion()])
    }
}
