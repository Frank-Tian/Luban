//
//  PodspecParser.swift
//  XcodeHelper
//
//  Created by Tian on 2020/11/16.
//

import Foundation
import Yams

class FlutterParser: PraserProtocol {
    
    static let shared = FlutterParser()
    private var _cardID = 0
    private var _dartVersion = ""
    private var _flutterVersion = ""
    private var _packages:[String: Any] = [:]

    func parseDependencies(lockContent: String?, specContent: String?) -> FlutterSDKInfo {
        var flutter: FlutterSDKInfo = FlutterSDKInfo.init(JSON: [:])!

        guard lockContent != nil else {
            Logger.echo("FlutterParser lockContent can't be nil", type: .warning)
            return flutter
        }
        
        guard specContent != nil else {
            Logger.echo("FlutterParser specContent can't be nil", type: .warning)
            return flutter
        }
        
        let packagesInUse:[SDKInfoItem] = parsePackageInUse(specContent: specContent!)
        _parsePubspecLock(lockContent: lockContent!)
        var packages:[SDKInfoItem] = []
        for sdk in packagesInUse {
            if let sdkName = sdk.name, let _sdk = _packages[sdkName] as? SDKInfoItem {
                packages.append(_sdk)
            }
        }
        flutter.cardID = _cardID
        flutter.packages = packages
        flutter.dartVersion = _dartVersion
        flutter.flutterVersion = _flutterVersion
        
        return flutter
    }
 
    /// 分行遍历获取依赖项
    fileprivate func parsePackageInUse(specContent: String) -> [SDKInfoItem] {
        var packages: [SDKInfoItem] = []
        do {
            let loadedDictionary = try Yams.load(yaml: specContent) as? [String: Any]
            if let dependencies = loadedDictionary?["dependencies"] as? [String: Any] {
                dependencies.keys.forEach { (name) in
                    var package = SDKInfoItem.init(JSON: [:])
                    package?.name = name
                    packages.append(package!)
                }
            }
            if let appKey = loadedDictionary?["app_key"] as? String {
                Setting.setAppKeyInYaml(appKey: appKey)
            }
            if let cardId = loadedDictionary?["card_id"] as? Int {
                _cardID = cardId
            }
        } catch {
            Logger.echo("FlutterParser parsePackageInUse failed!", type: .error)
        }
        return packages
    }
    
    /// 解析pubspec.lock 文件
    fileprivate func _parsePubspecLock(lockContent: String) {

        do {
            let loadedDictionary = try Yams.load(yaml: lockContent) as? [String: Any]
            if let sdks = loadedDictionary?["sdks"] as? [String: Any] {
                _dartVersion = sdks["dart"] as? String ?? ""
                _flutterVersion = sdks["flutter"] as? String ?? ""
            }
            if let packages = loadedDictionary?["packages"] as? [String: Any] {
                packages.keys.forEach { (name) in
                    if let sdk = packages[name] as? [String: Any] {
                        var package = SDKInfoItem.init(JSON: [:])
                        package?.name = name
                        package?.version = sdk["version"] as? String
                        package?.dependency = sdk["dependency"] as? String
                        package?.source = sdk["source"] as? String
                        if let desc = sdk["description"] as? [String: Any] {
                            var description = ""
                            desc.keys.sorted().forEach({ (item) in
                                description += "\(item): \(desc[item] ?? "")|"
                            })
                            package?.description = description
                        }
                        _packages[name] = package!
                    }
                }
            }
        } catch {
            Logger.echo("FlutterParser _parsePubspecLock failed!", type: .error)
        }
        
    }
}
