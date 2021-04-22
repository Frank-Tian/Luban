//
//  Request.swift
//  XcodeHelper
//
//  Created by Tian on 2020/11/13.
//

import Cocoa
import ObjectMapper
import Connectivity

enum ErrCode: Int {
    case Success = 0
    case ParseError = -100
    case RquestError = -1
}

let ParseErrorMessage = "接口数据解析错误"
let RequestErrorMessage = "接口请求失败"

public struct RequestError: Error {
    
    let code: Int
    let msg: String?
    let domain = "com.xxxx.XcodeHelper.Error"
}

public typealias RequestCompletion = ((_ data: [AnyHashable: Any]?, _ error: RequestError?) -> Void)

enum HttpMethod: String {
    case get = "GET"
    case post = "POST"
}

class NetworkProvider: NSObject {
    
}

extension NetworkProvider {
    
    class func request(url : String, params : [AnyHashable : Any]?, body: [AnyHashable : Any]?, method: HttpMethod = .get, completion : RequestCompletion?) {
        let session = URLSession(configuration: .default)
        var request = URLRequest(url: URL(string: fullURL(url))!)
        request.cachePolicy = .reloadIgnoringCacheData
        request.httpMethod = method.rawValue
        request.httpBody = jsonToData(body)
        request.timeoutInterval = 10
        request.allHTTPHeaderFields = customHeaders()
        let task = session.dataTask(with: request) {(data, response, error) in
            
            guard let finished = completion else {
                return
            }
            
            if let respData = data, error == nil {
                do {
                    let json = try JSONSerialization.jsonObject(with: respData, options: .allowFragments) as? [String: Any]
                    let errCode = json?["dm_error"] as? Int
                    let data = json?["data"] as? [String: Any]
                    var err: RequestError?
                    if errCode != 0 {
                        let msg = json?["error_msg"] as? String
                        err = RequestError.init(code: errCode!, msg:  msg)
                        Logger.echo(msg, type: .error)
                    }
                    finished(data, err)
                } catch {
                    Logger.echo(ParseErrorMessage, type: .error)
                    finished(nil, RequestError.init(code: ErrCode.ParseError.rawValue, msg: ParseErrorMessage))
                }
            } else {
                if let err = error as NSError? {
                    finished(nil, RequestError.init(code: err.code, msg: err.localizedDescription))
                } else {
                    Logger.echo(RequestErrorMessage, type: .error)
                    finished(nil, RequestError.init(code: ErrCode.RquestError.rawValue, msg: RequestErrorMessage))
                }
            }
        }
        task.resume()
    }
    class func get(url : String, params : [AnyHashable : Any]?, completion : RequestCompletion?) {
        request(url: url, params: params, body: nil, completion: completion)
    }
    
    class func post(url : String, params : [AnyHashable : Any]?, body : [AnyHashable : Any]?, completion : RequestCompletion?) {
        request(url: url, params: params, body: body, method: .post, completion: completion)
    }
}


extension NetworkProvider {
    
    class func get<T: Mappable>(url : String, params : [AnyHashable : Any]?, type: T.Type, completion : ((_ model: T?, _ error: RequestError?) -> Void)?) {
        
        NetworkProvider.get(url: url, params: params) { (response, err) in
            
            guard err == nil else {
                completion?(nil, err)
                return
            }
            if let data = response as? [String: Any] {
                completion?(T(JSON: data), err)
            } else {
                completion?(nil, err)
            }
        }
    }
    
    class func post<T: Mappable>(url : String, params : [AnyHashable : Any]?, body : [AnyHashable : Any]?, type: T.Type, completion : ((_ model: T?, _ error:RequestError?) -> Void)?) {
        
        NetworkProvider.post(url: url, params: params, body: body) { (response, err) in
            
            guard err == nil else {
                completion?(nil, err)
                return
            }
            if let data = response as? [String: Any] {
                completion?(T(JSON: data), err)
            } else {
                completion?(nil, err)
            }
        }
    }
}

extension NetworkProvider {
    
    class func fullURL(_ url: String) -> String! {
        if url.contains("http") {
            return url
        }
        return "\(Setting.baseURL())\(url)"
    }
    
    class func jsonToData(_ json: [AnyHashable : Any]?) -> Data? {
        
        guard JSONSerialization.isValidJSONObject(json as Any) else {
            print("JSON isValidJSONObject \(json ?? [:])")
            return nil
        }
        
        do {
            let data = try JSONSerialization.data(withJSONObject: json!, options: .fragmentsAllowed)
            return data
        } catch {
            print("JSON 解析失败 \(json ?? [:])")
            return nil
        }
    }
    
    class func customHeaders() -> [String : String]? {
        var headers:[String : String] = [:]
        headers["User-Agent"] = "XcodeHelper (\(Setting.scriptVersion()))"
        headers["uberctx-_namespace_appkey_"] = Setting.appKeyInSpec()
        return headers
    }
}

public typealias NetworkConnectivityChanged = ((Connectivity) -> Void)

class NetworkMonitor: NSObject {
    static let shared = NetworkMonitor()
    let connectivity: Connectivity
    var changed: NetworkConnectivityChanged?
    
    private override init() {
        connectivity = Connectivity()
    }
    
    deinit {
        Logger.echo("NetworkMonitor deinit!")
    }
}

extension NetworkMonitor {
    
    func startMonitor(changed: NetworkConnectivityChanged?) {
        self.changed = changed
        let connectivityChanged: (Connectivity) -> Void = {[weak self] connectivity in
            Logger.echo("network status changed: \(connectivity.status)")
            if let callback = self?.changed {
                callback(connectivity)
            }
        }
        connectivity.whenConnected = connectivityChanged
        connectivity.whenDisconnected = connectivityChanged
        connectivity.startNotifier()
    }
}

public extension Mappable {
    
    /// Initializes object from a JSON String
    init?(JSONString: String, context: MapContext? = nil) {
        if let obj: Self = Mapper(context: context).map(JSONString: JSONString) {
            self = obj
        } else {
            return nil
        }
    }
    
    /// Initializes object from a JSON Dictionary
    init?(JSON: [String: Any], context: MapContext? = nil) {
        if let obj: Self = Mapper(context: context).map(JSON: JSON) {
            self = obj
        } else {
            return nil
        }
    }
    
    static func modelFrom(JSON: [String: Any]) -> Self? {
        return self.init(JSON: JSON)
    }
}
