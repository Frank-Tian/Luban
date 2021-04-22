//
//  Model.swift
//  XcodeHelper
//
//  Created by Tian on 2020/11/13.
//

import Foundation
import ObjectMapper

/// ================================================================================
/// Request Model
/// ============================================================================

/// 应用程序信息
struct AppInfo: Mappable {
    var appKey: String?
    var displayName: String?
    var bundleID: String?
    var appVersion: String?
    var buildNum: String?
    var appType: String?
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        appKey      <- map["app_key"]
        displayName <- map["display_name"]
        bundleID    <- map["bundle_id"]
        appVersion  <- map["app_version"]
        buildNum    <- map["build_num"]
        appType     <- map["app_type"]
    }
}

/// IDE 信息 Xcode
struct IDEInfo: Mappable {
    var version: String?
    var podVersion: String?
    var buildVersion: String?
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        version         <- map["version"]
        podVersion      <- map["pod_version"]
        buildVersion    <- map["build_version"]
    }
}

/// 操作系统信息
struct OSInfo: Mappable {
    var osName: String?
    var productVersion: String?
    var buildVersion: String?
    var userName: String?
    var computerName: String?
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        osName         <- map["os_name"]
        productVersion <- map["product_version"]
        buildVersion   <- map["build_version"]
        userName       <- map["user_name"]
        computerName   <- map["computer_name"]
    }
}

/// shell 脚本信息
struct ScriptInfo: Mappable {
    var version: String?
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        version    <- map["version"]
    }
}

/// 依赖项SDK 信息
struct SDKInfoItem: Mappable {
    var name: String?
    var version: String?
    var sign: String?
    var repoUrl: String?
    
    // for flutter package only
    var source: String?
    var dependency: String?
    var description: String?

    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        name            <- map["name"]
        version         <- map["version"]
        sign            <- map["sign"]
        repoUrl         <- map["repoUrl"]
        source          <- map["source"]
        dependency      <- map["dependency"]
        description     <- map["description"]
    }
}

/// Flutter 信息
struct FlutterSDKInfo : Mappable {
    var cardID: Int = 0
    var dartVersion: String?
    var flutterVersion: String?
    var packages: [SDKInfoItem]?

    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        packages        <- map["packages"]
        dartVersion     <- map["dart_version"]
        flutterVersion  <- map["flutter_version"]
        cardID          <- map["card_id"]
    }
}

/// 原生依赖信息
struct NativeSDKInfo : Mappable {
    var cardID: Int = 0
    var sdks: [SDKInfoItem]?
    var podlockChecksum: String?
    var podVersion: String?

    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        sdks            <- map["sdks"]
        cardID          <- map["card_id"]
        podVersion      <- map["pod_version"]
        podlockChecksum <- map["podlock_checksum"]
    }
}

/// SDK 依赖信息
struct SDKDependencies: Mappable {
    var flutter: FlutterSDKInfo?
    var native: NativeSDKInfo?
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        flutter    <- map["flutter"]
        native     <- map["native"]
    }
}

/// 数据采集请求模型
struct SignCheckReuqest: Mappable {
    var app: AppInfo?
    var ide: IDEInfo?
    var os: OSInfo?
    var script: ScriptInfo?
    var dependencies: SDKDependencies?
    var buildEnv: Int = 0
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        app             <- map["app"]
        ide             <- map["ide"]
        os              <- map["os"]
        os              <- map["os"]
        buildEnv        <- map["build_env"]
        script          <- map["script"]
        dependencies    <- map["dependencies"]
    }
}

/// 版本升级请求
struct VersionCheckRequest: Mappable {
    var app: AppInfo?
    var cardID: Int = 0
    var cardIDFlutter: Int?
    var script: ScriptInfo?
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        app             <- map["app"]
        cardID          <- map["native_card_id"]
        cardIDFlutter   <- map["flutter_card_id"]
        script          <- map["script"]
    }
}

/// ================================================================================
/// Response Model
/// ============================================================================

/// 校验结果响应
struct SignCheckResult: Mappable {
    var checkResult: Bool = true
    var checkInfo: String = ""
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        checkResult     <- map["sign_check_result"]
        checkInfo       <- map["sign_check_info"]
    }
}

/// 版本升级请求响应
struct VersionCheckResult: Mappable {
    var packagesChanged: Bool = false
    var packagesChangeInfo: String = ""
    var scriptChanged: Bool = false
    var scriptChangeInfo: String  = ""
    var cloudUrl: String = ""

    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        packagesChanged         <- map["packages_if_change"]
        packagesChangeInfo      <- map["packages_change_info"]
        scriptChanged           <- map["script_if_change"]
        scriptChangeInfo        <- map["script_change_info"]
        cloudUrl                <- map["cloud_url"]
    }
}
