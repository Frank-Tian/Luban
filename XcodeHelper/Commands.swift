//
//  Command.swift
//  XcodeHelper
//
//  Created by Tian on 2020/11/14.
//

import Foundation

class Commands {
    
    private static var _sdkDependencies: SDKDependencies?
    
    class func versionCheck(_ completion: ((_ success: Bool) -> Void)?) {
        let url = "/api/v1/build/check"
        var req = VersionCheckRequest.modelFrom(JSON: [:])
        req?.app = DataCollector.getAppInfo()
        req?.cardID = getDependencies()?.native?.cardID ?? 0
        req?.cardIDFlutter = getDependencies()?.flutter?.cardID
        req?.script = DataCollector.getScriptInfo()
        
        NetworkProvider.post(url: url, params: nil, body: req?.toJSON(), type: VersionCheckResult.self) { (res, err) in

            guard err == nil, let info = res else {
                AlertHelper.showErrorTips(err?.msg) { (ok) in
                    completion?(false)
                }
                return
            }
            
            // 每天提现 x 次
            if info.packagesChanged {
                Logger.echo("Version Check, packagesChanged~")
                if PopPolicy.shouldPoppUpSDKUpdateAlert() {
                    AlertHelper.showDialog("发现依赖SDK新版本", content: info.packagesChangeInfo) { (ok) in
                        if ok {
                            ShellHelper.openBrowser(info.cloudUrl)
                            Logger.echo("PackagesChanged, openBrowser \(info.cloudUrl)")
                        } else {
                            Logger.echo("PackagesChanged, skip~", type: .warning)
                        }
                    }
                }
            }
            
            if info.scriptChanged {
                Logger.echo("Version Check, scriptChanged~")
                if PopPolicy.shouldPoppUpScriptUpdateAlert() {
                    AlertHelper.showDialog("发现构建脚本更新", content: info.scriptChangeInfo) { (ok) in
                        if ok {
                            ShellHelper.openBrowser(info.cloudUrl)
                            Logger.echo("ScriptChanged, openBrowser \(info.cloudUrl)")
                        } else {
                            Logger.echo("ScriptChanged, skip~", type: .warning)
                        }
                        completion?(true)
                    }
                } else {
                    completion?(true)
                }
            } else {
                completion?(true)
            }
        }
    }

    class func signCheck(completion: ((_ success: Bool) -> Void)?) {
        let url = "/api/v1/build/info/add"
        var req = SignCheckReuqest.modelFrom(JSON: [:])
        req?.app = DataCollector.getAppInfo()
        req?.ide = DataCollector.getIDEInfo()
        req?.os = DataCollector.getOSInfo()
        req?.dependencies = getDependencies()
        req?.script = DataCollector.getScriptInfo()
        req?.buildEnv = Setting.getBuildEnv().rawValue
        NetworkProvider.post(url: url, params: nil, body: req?.toJSON(), type: SignCheckResult.self) { (res, err) in
            guard err == nil, let info = res else {
                AlertHelper.showErrorTips(err?.msg) { (ok) in
                    completion?(false)
                }
                return
            }
            
            if !info.checkResult {
                if PopPolicy.shouldPoppUpWarningAlert()  {
                    AlertHelper.showAlert("重要提醒", content: info.checkInfo, completion: { (ok) in
                        Logger.echo("Sign Check, Has been prompted~")
                        completion?(true)
                    }, type: .critical)
                } else {
                    completion?(true)
                }
            } else {
                completion?(true)
            }
        }
    }
    
    class func getProjectRootDir() -> Bool {
#if HELPER
        let root = "/Users/xxxx/client/Script/XcodeHelper"
        Logger.echo("开发模式，读取默认工程目录：\(root)")
        Setting.setProjectRoot(path: root)
        return true
#endif
        
        guard let output = ShellHelper.getProjectRoot(), output.count > 5 else {
            return false
        }
        Setting.setProjectRoot(path: output)
        
        if let flutterRoot = ShellHelper.getFlutterRoot(), flutterRoot.count > 5 {
            Setting.setFlutterProject(path: flutterRoot)
        }
        
        return true
    }
    
    @discardableResult
    class func getDependencies() -> SDKDependencies? {
        if _sdkDependencies == nil {
            // 区分原生项目，还是flutter 项目
            // 文件位置存储的地方，动态获取，支持配置
            _sdkDependencies = SDKDependencies.init(JSON: [:])
            if !Setting.pureFlutterIntegrate() {
                guard let podSpecData = FileReader.shared.readFile(path: Setting.pathForFile(dir: Setting.projectRoot(), name: .nwPodSpec)) else {
                    AlertHelper.showErrorTips("没有发现 \(FileName.nwPodSpec.rawValue) 文件~")
                    return nil
                }
                guard let podfileLockData = FileReader.shared.readFile(path: Setting.pathForFile(dir: Setting.projectRoot(), name: .podfileLock)) else {
                    AlertHelper.showErrorTips("没有发现 \(FileName.podfileLock.rawValue) 文件~")
                    return nil
                }
                _sdkDependencies?.native = PodfileParser.shared.parseDependencies(lockContent: podfileLockData, specContent: podSpecData)
            }

            if Setting.flutterEnabled() {
                let specFilePath = Setting.pathForFile(dir: Setting.flutterProject(), name: .nwFlutterSpec)
                guard let flutterSpecData = FileReader.shared.readFile(path: specFilePath) else {
                    AlertHelper.showErrorTips("没有发现 \(FileName.nwFlutterSpec.rawValue) 文件~")
                    return nil
                }
                let lockFilePath = Setting.pathForFile(dir: Setting.flutterProject(), name: .pubspecLock)
                guard let pubspecLockData = FileReader.shared.readFile(path: lockFilePath) else {
                    AlertHelper.showErrorTips("没有发现 \(FileName.pubspecLock.rawValue) 文件~")
                    return nil
                }
                _sdkDependencies?.flutter = FlutterParser.shared.parseDependencies(lockContent: pubspecLockData, specContent: flutterSpecData)
            }
        }
        return _sdkDependencies
    }
    
}
