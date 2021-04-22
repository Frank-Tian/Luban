//
//  AlertHelper.swift
//  XcodeHelper
//
//  Created by Tian on 2020/11/13.
//

import Cocoa

enum AlertType {
    case normal
    case critical
}

typealias AlertActionBlock = (_: Bool) -> ()

class AlertHelper: NSObject {

    class func showDialog(_ title: String, content: String , completion: AlertActionBlock? = nil) {
        let cmd = "osascript -e ' display dialog \"\(content)\" with title \"\(title)\" '"
        ShellExecutor.execute(cmd) { (output) in
            if let res = output, completion != nil {
                completion!(!(res.contains("error")))
            }
        }
    }
    
    class func showNotification(_ title: String, content: String, completion: AlertActionBlock? = nil) {
        let cmd = "osascript -e 'display notification \"\(content)\" with title \"\(title)\"'"
        ShellExecutor.execute(cmd) { (output) in
            if let _ = output, completion != nil {
                completion!(true)
            }
        }
    }
    
    class func showAlert(_ title: String, content: String, completion: AlertActionBlock? = nil, type: AlertType = .critical) {
        let typeStr = (type == .normal ? "" : "as critical")
        let cmd = "osascript -e 'display alert \"\(title)\" message \"\(content)\" \(typeStr)'"
        ShellExecutor.execute(cmd) { (output) in
            if let _ = output, completion != nil {
                completion!(true)
            }
        }
    }
    
    class func showErrorTips(_ tips: String?, completion: AlertActionBlock? = nil) {
        guard Setting.alertEnabled() else {
            if completion != nil {
                completion!(false)
            }
            return
        }
        AlertHelper.showAlert("出错啦~", content: tips ?? "") { (ok) in
            if completion != nil {
                completion!(true)
            }
        }
    }
}
