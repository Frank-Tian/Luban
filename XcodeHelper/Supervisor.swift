//
//  Supervisor.swift
//  XcodeHelper
//
//  Created by Tian on 2020/11/13.
//

import Cocoa

let DefaultWatchDogDuration: TimeInterval = 60

class Supervisor: NSObject {

    class func start() {
        Logger.echo("Supervisor start~", type: .info)
        startWatchDog(DefaultWatchDogDuration)
    }
    
    class func runloop() {
        Logger.echo("Supervisor run~", type: .info)
        RunLoop.current.run()
    }
    
    /// 停止程序
    /// - Parameter delay: 延迟时间
    class func stop(_ delay: TimeInterval = 0, success: Bool = true) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            if delay > 5 {
                AlertHelper.showErrorTips("任务执行超时~")
            }
            let code: Int32 = success ? 0 : 1
            Logger.echo("Supervisor stop~ code: \(code)", type: .info)
            exit(code)
        }
    }
    
    /// 开启看门狗
    /// - Parameter maxDuration: 最大时长
    class func startWatchDog(_ maxDuration: TimeInterval) {
        Logger.echo("Supervisor watchdog~ \(DefaultWatchDogDuration)", type: .info)
        stop(maxDuration)
    }
}
