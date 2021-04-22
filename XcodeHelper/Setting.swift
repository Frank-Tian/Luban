//
//  Setting.swift
//  XcodeHelper
//
//  Created by Tian on 2020/11/14.
//

import Foundation

struct Constants {
    static let ScriptVersion = "0.1.0"
    static let APIVersion = ""
    static let BASE_URL = "http://testapi.xxxxxx.com"
//    static let BASE_URL = "https://api.xxxxxx.com"
}

enum FileName: String {
    case podfileLock = "Podfile.lock"
    case pubspecLock = "pubspec.lock"
    case nwPodSpec = "NWServicesSDK.podspec"
    case nwFlutterSpec = "flutter_nvwa/pubspec.yaml"
}

enum UserStoreKey: String {
    case latestSDKUpdateShowTime    = "SDKAlertShowTime"
    case latestScriptUpdateShowTime = "ScriptAlertShowTime"
    case localTotoalBuildCount      = "totoalBuildCount"
}

enum BuildEnv: Int {
    case debug = 0
    case release = 1
}

class Setting {
    
    private static var _appKeyInSpec: String = ""
    private static var _appKeyInYaml: String = ""
    private static var _projectRoot: String = ""
    private static var _flutterProject: String = ""
    private static var _flutterEnabled: Bool = false
    private static var _pureFlutterIntegrate: Bool = false
    private static var _skipAlertScheme: [String] = []

    class func scriptVersion() -> String {
        return Constants.ScriptVersion
    }
    
    class func appKeyInSpec() -> String {
        return _appKeyInSpec
    }
    
    class func setAppKeyInSpec(appKey: String) {
        _appKeyInSpec = appKey
    }
    
    class func appKeyInYaml() -> String {
        return _appKeyInYaml
    }
    
    class func setAppKeyInYaml(appKey: String) {
        _appKeyInYaml = appKey
    }
    
    class func setFlutterProject(path: String) {
        _flutterProject = path
    }
    
    class func flutterProject() -> String {
        return _flutterProject
    }
    class func setFlutterEnabled(enabled: Bool) {
        _flutterEnabled = enabled
    }
    
    class func flutterEnabled() -> Bool {
        return _flutterEnabled
    }
    
    class func setPureFlutterIntegrate(pure: Bool) {
        _pureFlutterIntegrate = pure
    }
    
    class func pureFlutterIntegrate() -> Bool {
        return _pureFlutterIntegrate
    }
    
    class func setSkipAlert(schemes: [String]) {
        _skipAlertScheme = schemes
    }
    
    /// 是否展示Alert
    /// 根据配置的跳过 scheme 进行区分
    class func alertEnabled() -> Bool {
        let env = ShellHelper.getBuildConfig() ?? ""
        return !_skipAlertScheme.contains(env)
    }
    
    class func baseURL() -> String {
        return Constants.BASE_URL
    }
    
    class func setProjectRoot(path: String) {
        guard path.count > 0 else {
            Logger.echo("设置ProjectRoot错误：path 不能为空", type: .error)
            return
        }
        Logger.echo("setProjectRoot success~")
        if path != _projectRoot {
            _projectRoot = path
        }
    }
    
    class func projectRoot() -> String {
        return _projectRoot
    }
    
    class func pathForFile(dir: String, name: FileName) -> String {
        return "\(dir)/\(name.rawValue)"
    }
    
    class func storeValue(value: Any?, forKey:String ) {
        UserDefaults.standard.setValue(value, forKey: forKey)
        UserDefaults.standard.synchronize()
    }
    
    class func value(forKey: String) -> Any? {
        UserDefaults.standard.value(forKey: forKey)
    }
    
    class func getBuildEnv() -> BuildEnv {
        let env = ShellHelper.getBuildConfig()
        switch env {
        case "Release":
            return .release
        default:
            return .debug
        }
    }
}
