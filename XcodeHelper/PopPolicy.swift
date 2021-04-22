//
//  PopPolicy.swift
//  XcodeHelper
//
//  Created by Tian on 2020/11/14.
//

import Foundation

class PopPolicy {
    static let formatter = DateFormatter(withFormat: "yyyy-MM-dd", locale: "zh_CN")
    /// 最大每日升级提醒次数
    static var maxScriptUpdateTipsCountDaily: Int = 5
    static var maxSDKUpdateTipsCountDaily: Int = 5
    static var maxWarningTipsCountDaily: Int = 100

    class func shouldPoppUpSDKUpdateAlert() -> Bool {
        let key = "SDKUpdate|\(formatter.string(from: Date.init()))"
        return checkAndUpdate(key: key, max: maxSDKUpdateTipsCountDaily)
    }
    
    class func shouldPoppUpScriptUpdateAlert() -> Bool {
        let key = "ScriptUpdate|\(formatter.string(from: Date.init()))"
        return checkAndUpdate(key: key, max: maxScriptUpdateTipsCountDaily)
    }
    
    class func shouldPoppUpWarningAlert() -> Bool {
        let key = "Warning|\(formatter.string(from: Date.init()))"
        return checkAndUpdate(key: key, max: maxWarningTipsCountDaily)
    }
    
    fileprivate class func checkAndUpdate(key: String, max: Int) -> Bool {
        
        let shortKey = String(describing: (key.split(separator: "|").first!))
        guard Setting.alertEnabled() else {
            Logger.echo("PopPolicy:\(shortKey) skip, env: !debug")
            return false
        }
        
        if var count = Setting.value(forKey: key) as? Int {
            Logger.echo("checkAndUpdate: \(shortKey) \(count)")
            if count >= max {
                return false
            }
            count += 1
            Setting.storeValue(value: count, forKey: key)
        } else {
            Setting.storeValue(value: 1, forKey: key)
        }
        return true
    }
}
