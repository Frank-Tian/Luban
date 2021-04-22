//
//  PodfileParser.swift
//  XcodeHelper
//
//  Created by Tian on 2020/11/16.
//

import Foundation

/// Podfile 解析类
/// 目前的方案是手动解析，不够优雅
/// 实际可以将 - 去除，然后作为一个 Yaml 文件来进行解析
/// 详细可参阅：FlutterParser
/// 时间比较紧，目前没有空去优化这一块
class PodfileParser: PraserProtocol {
 
    let sectionPods = "PODS:"
    let sectionSpecRepos = "SPEC REPOS:"
    let sectionDependencies = "DEPENDENCIES:"
    let sectionExternalSources = "EXTERNAL SOURCES:"
    let sectionSpecCheckSums = "SPEC CHECKSUMS:"
    let sectionPodfileCheckSum = "PODFILE CHECKSUM:"
    let sectionCocoapods = "COCOAPODS:"
    
    static let shared = PodfileParser()
    
    private var _checksumForSDK:[String: String] = [:]
    private var _versionsForSDK:[String: String] = [:]
    private var _reopsForSDK:[String: String] = [:]
    private var _podfileCheckSum = ""
    private var _podVersion = ""
    private var _cardID = 0

    func parseDependencies(lockContent: String?, specContent: String?) -> NativeSDKInfo {
        var native: NativeSDKInfo = NativeSDKInfo.init(JSON: [:])!

        guard lockContent != nil else {
            Logger.echo("PodfileParser lockContent can't be nil", type: .warning)
            return native
        }
        
        guard specContent != nil else {
            Logger.echo("PodfileParser specContent can't be nil", type: .warning)
            return native
        }
        
        parsePodfileLock(lockContent: lockContent!)
        let sdkInUse:[SDKInfoItem] = parseSDKInUse(specContent: specContent!)
        var sdks:[SDKInfoItem] = []
        for sdk in sdkInUse {
            var sdk = sdk
            if let name = sdk.name {
                sdk.version = _versionsForSDK[name]
                sdk.repoUrl = _reopsForSDK[name]
                sdk.sign = _checksumForSDK[name]
            }
            sdks.append(sdk)
        }
        
        native.podlockChecksum = _podfileCheckSum
        native.podVersion = _podVersion
        native.cardID = _cardID
        native.sdks = sdks
        
        return native
    }
    
    /// 分行遍历获取依赖项
    /// 查找出版本号、appKey
    /// 查找出依赖项，示例：spec.dependency 'IKVideoSDK', '8.1.00.13-nvwa'
    /// 处理规则：
    /// 1、移除 spec.dependency， 'IKVideoSDK', '8.1.00.13-nvwa'
    /// 2、替换掉空格、引号  IKVideoSDK, 8.1.00.13-nvwa
    /// 3、根据逗号分组，["IKVideoSDK", "8.1.00.13-nvwa"]
    fileprivate func parseSDKInUse(specContent: String) -> [SDKInfoItem] {
        var sdks:[SDKInfoItem] = []
        let lines = specContent.components(separatedBy: "\n")
        lines.forEach { (line) in
            switch line {
            /// cardId
            case let line where line.contains("# Version:"):
                let cid = line.components(separatedBy: ":").last ?? ""
                _cardID = Int(cid) ?? 0
            /// Appkey
            case let line where line.contains("# AppKey:"):
                let appKey = line.components(separatedBy: ":").last ?? ""
                Setting.setAppKeyInSpec(appKey: appKey)
            /// 依赖项
            case let line where line.contains("spec.dependency"):
                var sdkDep = line.replacingOccurrences(of: "spec.dependency", with: "")
                sdkDep = sdkDep.replacingOccurrences(of: " ", with: "")
                    .replacingOccurrences(of: "'", with: "")
                    .replacingOccurrences(of: "\t", with: "")
                let arr = sdkDep.components(separatedBy: ",")
                if let sdkName = arr.first, let sdkVersion = arr.last {
                    if var sdk = SDKInfoItem.modelFrom(JSON: [:]) {
                        sdk.name = String(sdkName)
                        sdk.version = String(sdkVersion)
                        sdks.append(sdk)
                    }
                }
            default:
                break
            }
        }
        return sdks
    }
    
    /// 分组遍历获取SDK 信息
    /// 查找SDK 名称、版本号、sum值
    fileprivate func parsePodfileLock(lockContent: String) {
        
        let sections = lockContent.components(separatedBy: "\n\n")
        
        sections.forEach { (section) in
            switch section {
            case let section where section.hasPrefix(sectionPods):
                _parsePodSections(content: section)
            case let section where section.hasPrefix(sectionDependencies):
                _parseDependencies(content: section)
            case let section where section.hasPrefix(sectionSpecRepos):
                _parseReposForSDK(content: section)
            case let section where section.hasPrefix(sectionExternalSources):
                _parseExternalSources(content: section)
            case let section where section.hasPrefix(sectionSpecCheckSums):
                _parseSpecCheckSum(content: section)
            case let section where section.hasPrefix(sectionPodfileCheckSum):
                _podfileCheckSum = section.components(separatedBy: ":").last ?? ""
            case let section where section.hasPrefix(sectionCocoapods):
                _podVersion = section.replacingOccurrences(of: "\n", with: "").components(separatedBy: ":").last ?? ""
            default:
                ()
            }
        }
    }
    
    fileprivate func _parsePodSections(content: String) {
        
        func parsePodLine(_ line: String) {
            let prefix = "  - "
            if line.hasPrefix(prefix) {
                let fillterChars = [prefix, "(", ")", ":"]
                var spec = line
                for ch in fillterChars {
                    spec = spec.replacingOccurrences(of: ch, with: "")
                }
                let components = spec.components(separatedBy: " ")
                if var name = components.first, let version = components.last {
                    let separator: Character = "/"
                    if name.contains(separator), let shortName = name.split(separator: separator).first {
                        name = String(shortName)
                    }
                    _versionsForSDK[name] = version
                }
            }
        }
        
        let lines = content.components(separatedBy: "\n")
        lines.forEach { (line) in
            parsePodLine(line)
        }
    }
    
    fileprivate func _parseDependencies(content: String) {
        //...
    }
    
    fileprivate func _parseReposForSDK(content: String) {
        
        let lines = content.replacingOccurrences(of: sectionSpecRepos , with: "").components(separatedBy: "\n")
        var lastKey:String?
        
        lines.forEach { (line) in
            if line.contains(":") {
                lastKey = line.trimmingCharacters(in: [" ", ":", "\""])
            }
            
            if line.contains(" - ") {
                let sdkName = line.trimmingCharacters(in: [" ", "\t", "-"])
                _reopsForSDK[sdkName] =  lastKey
            }
        }
    }
    
    fileprivate func _parseExternalSources(content: String) {
        //...
    }
    
    fileprivate func _parseSpecCheckSum(content: String) {
        
        func parseCheckSumLine(_ line: String) {
            let prefix = "  "
            if line.hasPrefix(prefix) {
                let fillterChars = [" "]
                var spec = line
                for ch in fillterChars {
                    spec = spec.replacingOccurrences(of: ch, with: "")
                }
                let components = spec.components(separatedBy: ":")
                if let name = components.first, let sum = components.last {
                    _checksumForSDK[name] = sum.replacingOccurrences(of: " ", with: "")
                }
            }
        }
        
        let lines = content.components(separatedBy: "\n")
        lines.forEach { (line) in
            parseCheckSumLine(line)
        }
    }
}


