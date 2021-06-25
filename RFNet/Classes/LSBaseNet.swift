//
//  LSBaseNet.swift
//  RFNet
//
//  Created by zrf on 2021/6/24.
//

import Foundation
import Alamofire


//MARK: 基本网络请求
public struct LSBaseNet {
    public static var shared = LSBaseNet()
    public var config: LSConfigNetProtocol?
    private init() {}
    /**
     @brief get请求
     @discussion
     */
    public mutating func get(_ apiName:String, params:[String: String]? = nil, headers:[String: String]? = nil,success:((String?, Any)->Void)?=nil, failure:((String?, Dictionary<String,Any>)->Void)?=nil){
       // 当带params时， encoder使用URLEncodedFormParameterEncoder.default。经验证，使用JSONParameterEncoder在带参数时请求异常
        request(url(apiName), method: .get, headers: headers, encoder: URLEncodedFormParameterEncoder.default,
                success:{ url,result  in
                    if let succ = success{
                        succ(url, result)
                    }
            
        }){ url, result in
            if let fail = failure {
                fail(url, result)
            }
        }
    }
    /**
     @brief post请求
     */
    public mutating func post(_ apiName:String, params:[String: String]? = nil, headers:[String: String]? = nil, success:((String?, Any)->Void)?=nil, failure:((String?, Dictionary<String,Any>)->Void)?=nil){
        request(url(apiName), method:.post, params: params, headers:headers, encoder:URLEncodedFormParameterEncoder.default, success:{ url,result  in
            if let succ = success{
                succ(url, result)
            }
            
        }){ url, result in
            if let fail = failure {
                fail(url, result)
            }
        }
    }
    
    
    /**
     @brief 请求
     @discussion 当带params时， encoder使用URLEncodedFormParameterEncoder.default。经验证，使用JSONParameterEncoder在带参数时请求异常
     */
    fileprivate mutating func request(_ apiName:String, method:HTTPMethod,params:[String: String]? = nil, headers:[String: String]? = nil, encoder: ParameterEncoder, filter:RequestInterceptor? = nil, success:((String?, Any)->Void)?=nil, failure:((String?, Dictionary<String,Any>)->Void)?=nil) {
        guard let cfg = config else {
            fatalError("网络配置未完成，无法使用")
        }
        //默认参数处理
        var paramsDict = params
        if let p = cfg.commonParams() {
            paramsDict = paramsDict ?? Dictionary()
            paramsDict?.merge(p, uniquingKeysWith: { old, new in
                return new
            })
        }
        //默认Header处理
        var headerDict = headers
        if let p = cfg.commonHeaders() {
            headerDict = headerDict ?? Dictionary()
            headerDict?.merge(p, uniquingKeysWith: { old, new in
                return new
            })
        }
        let paramEncoder = cfg.bEncrypt ? EncryptParameterEncoder(config: cfg) : encoder
        //JSONParameterEncoder.default
        if cfg.bEncrypt {  //返回格式定义为字符串
            AF.request(url(apiName), method:method, parameters: paramsDict, encoder: paramEncoder , headers: header(headerDict), interceptor:cfg.bRetry ? CustomRequestInterceptor(config: cfg) : nil, requestModifier: nil).responseString { response in
                debugPrint(response)
                switch response.result {
                    case .failure(let error):
                        if let fail = failure {
                            fail(response.request?.url?.absoluteString, ["code": error.responseCode ?? -1, "msg": error.localizedDescription
                            ])
                        }
                    case .success(let str):
                        let encryptStr: String = str
                        let dict:Dictionary = cfg.commonDecrypt(encryptStr)
                        if let code = dict["code"], code as! Int != 200 {
                            if let fail = failure {
                                fail(response.request?.url?.absoluteString, ["code": code , "msg": dict["message"] as! String
                                ])
                            }
                        }else{
                            if let succ = success {
                                succ(response.request?.url?.absoluteString, dict["result"] as Any)
                            }
                        }

                    return
                }
            }
        }else{
            AF.request(url(apiName), method:method, parameters: paramsDict, encoder: paramEncoder , headers: header(headerDict), interceptor:cfg.bRetry ? CustomRequestInterceptor(config: cfg) : nil, requestModifier: nil).responseJSON { response in
                debugPrint(response)
                switch response.result {
                    case .failure(let error):
                        if let fail = failure {
                            fail(response.request?.url?.absoluteString, ["code": error.responseCode ?? -1, "msg": error.localizedDescription
                            ])
                        }
                    case .success(let JSON):
                        let dict: Dictionary<String, Any> = JSON as! Dictionary<String, Any>
                        if let code = dict["code"], code as! Int != 200 {
                            if let fail = failure {
                                fail(response.request?.url?.absoluteString, ["code": code , "msg": dict["message"] as! String
                                ])
                            }
                        }else{
                            if let succ = success {
                                succ(response.request?.url?.absoluteString, dict["result"] as Any)
                            }
                        }

                    return
                }
            }
        }
        
    }
    
}
//MARK: 网络请求接口传参处理
extension LSBaseNet {
    /**
     @brief 对参数进行处理，转换为HttpHeaders对象
     */
    fileprivate func header(_ dict:[String:String]?)-> HTTPHeaders?{
        if let d = dict {
            return HTTPHeaders(d)
        }
        return nil
    }
    /**
     @brief 对apiName进行处理
     @discussion 当传入的apiname带http链接时，使用原apiName. 否则自动拼接BaseUrlStr到Apiname前
     @author rf/2021-06-24
     */
    fileprivate mutating func url(_ apiName: String) -> String{
        if config?.baseUrlStr == nil {  //未配置baseUrl，直接返回
            return apiName
        }
        if apiName.isEmpty {
            return config?.baseUrlStr ?? ""
        }
        if !apiName.hasPrefix("http"){  //传入的apiName不带scheme
            if let base = config?.baseUrlStr {
                if base.hasSuffix("/") { //BaseUrl末尾已包括斜杠
                    if apiName.hasPrefix("/") {  //apiName错误传值，修正
                        var api = apiName
                        api.removeFirst()
                        return base + api
                    }
                    return base + apiName
                }else{
                    if apiName.hasPrefix("/") {
                        return base + apiName
                    }
                    return base + "/" + apiName
                }
            }
        }
        return apiName
    }
}

//自定义适配与重试机制. 无特殊使用场景，此类可忽视
//RequestInterceptor 协议（RequestAdapter & RequestRetrier）提供了请求适配器和重试功能
//RequestAdapter 协议 功能非常有用，比如说设置请求头Token, 或其他修改Request操作
//RequestRetrier 请求失败重试
 struct CustomRequestInterceptor: RequestInterceptor {
    var config:LSConfigNetProtocol
    public func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        let request = urlRequest
        
//        request.headers.add(.authorization(bearerToken: ""))
        completion(.success(config.customAdapt(request)))
    }

    public func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        if request.retryCount < 3{  //每个接口失败，增加3次重试服务. 接口回调会在3次完成后进行
            completion(.retryWithDelay(1))
        } else {
            completion(.doNotRetry)
        }
    }
    
}
//加密编码
class EncryptParameterEncoder:URLEncodedFormParameterEncoder{
    var cfg:LSConfigNetProtocol
    init(config:LSConfigNetProtocol) {
        cfg = config
        super.init()
    }
    override func encode<Parameters>(_ parameters: Parameters?, into request: URLRequest) throws -> URLRequest where Parameters : Encodable {
        let jsonData = try? JSONSerialization.data(withJSONObject: parameters!, options: [])
        let jsonStr = String(data: jsonData!, encoding: .utf8)
        var request = request
        if let encrypt = cfg.commonEncrypt(jsonStr) {
            request.httpBody = encrypt
            return request
        }else{
            return try super.encode(parameters, into: request)
        }
    }
}

