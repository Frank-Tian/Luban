//
//  main.swift
//  XcodeHelper
//
//  Created by Tian on 2020/11/12.
//

import Foundation

/// 数据收集流程
/// 1、启动之后开启 watchdog，设置最大执行时间
/// 2、获取项目根目录
///     获取不到进行提示
///     获取到进行下一步
///     3、检查依赖项文件
///         内部判断工程类型
///     4、网络连接状态检查
///         未联网进行本地记录，进行提示
///         网络正常进行下一步
///             5、进行采集上报信息
///                 提示、提醒
///

Supervisor.start()
readCommandLineArgs()
mainStep();
Supervisor.runloop()
func mainStep() {
    
    guard Commands.getProjectRootDir() else {
        AlertHelper.showErrorTips("获取项目目录失败！")
        Logger.echo("getProjectRootDir failed!", type: .error)
        Supervisor.stop(success: false)
        return
    }
    
    guard (Commands.getDependencies() != nil) else {
        Logger.echo("getDependencies failed!", type: .error)
        Supervisor.stop(success: false)
        return
    }
    
    NetworkMonitor.shared.startMonitor { (activity) in
        
        guard activity.status != .notConnected else {
            Logger.echo("Network is unavailable, Saving session ~", type: .error)
            // Writ Local
            AlertHelper.showErrorTips("您当前未联网，本次构建信息可能不会被同步到管控中心~") { (ok) in
                Supervisor.stop()
            }
            return
        }
        infoUpload()
    }
}

func infoUpload() {
    
    Logger.echo("Network is available, Upload now ~")
    Logger.echo("do signCheck now ~")
    Commands.signCheck { (success) in
        if success {
            Logger.echo("do versionCheck now ~")
            Commands.versionCheck{ (finished) in
                if finished {
                    Logger.echo("Upload Success, stop now ~")
                    Supervisor.stop()
                } else {
                    Logger.echo("versionCheck failed, stop now ~")
                    Supervisor.stop(success: true)  // false block
                }
            }
        } else {
            Logger.echo("signCheck failed, stop now ~")
            Supervisor.stop(success: true)  // false block
        }
    }
}

func readCommandLineArgs() {
    for argument in CommandLine.arguments {
        switch argument {
        case let argument where argument.contains("flutter=1"):
            Setting.setFlutterEnabled(enabled: true)
        case let argument where argument.contains("pureFlutter=1"):
            Setting.setPureFlutterIntegrate(pure: true)
        case let argument where argument.contains("skipAlert="):
            if let schemes = argument.split(separator: "=").last {
                let arr = schemes.split(separator: ",").map { String($0) }
                Setting.setSkipAlert(schemes: arr)
            }
        default:
            ()
        }
        print(argument)
    }
}


