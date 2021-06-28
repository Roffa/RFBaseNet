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
    public static var requestDict: Dictionary<String, Request> = Dictionary()  //存储网络请求信息
    static let sema = DispatchSemaphore(value: 1)
    
    private init() {  LSNetworkStatusManager.share.startListening()  }
    /**
     @brief get请求
     @return 返回请求唯一标识, 需要持有请求时使用
     @discussion
     */
    @discardableResult
    public mutating func get(_ apiName:String, params:[String: String]? = nil, headers:[String: String]? = nil,success:((String?, Any)->Void)?=nil, failure:((String?, Dictionary<String,Any>)->Void)?=nil) -> String?{
       // 当带params时， encoder使用URLEncodedFormParameterEncoder.default。经验证，使用JSONParameterEncoder在带参数时请求异常
        return request(url(apiName), method: .get, headers: headers, encoder: URLEncodedFormParameterEncoder.default,
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
     @return 返回请求唯一标识, 需要持有请求时使用
     */
    @discardableResult
    public mutating func post(_ apiName:String, params:[String: String]? = nil, headers:[String: String]? = nil, success:((String?, Any)->Void)?=nil, failure:((String?, Dictionary<String,Any>)->Void)?=nil) -> String?{
        return request(url(apiName), method:.post, params: params, headers:headers, encoder:URLEncodedFormParameterEncoder.default, success:{ url,result  in
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
     @brief 上传文件请求
     @param apiName 接口名， 可以为完整的url地址，非完整url自动拼接baseurlStr
     @param files 需上传的文件字典   文件名：data
     @param isPost 是否为post请求
     @return 返回请求唯一标识, 需要持有请求时使用
     @author rf/2021-06-28
     */
    @discardableResult
    public mutating func upload(_ apiName:String, files:[String: Data]? = nil, headers:[String: String]? = nil, isGet:Bool = false, mimeType:String?=nil, success:((String?, Any)->Void)?=nil, failure:((String?, Dictionary<String,Any>)->Void)?=nil, progressClosure: ((Double)->Void)? ) -> String?{
//        let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory)
        guard let url = URL(string: url(apiName))  else {
            fatalError("LSBaseNet上传地址异常")
        }
        guard let cfg = config else {
            fatalError("LSBaseNet网络配置未完成，无法使用")
        }
        guard let files = files, files.count > 0 else {
            fatalError("LSBaseNet上传文件为空，失败")
        }
        //默认Header处理
        var headerDict = headers
        if let p = cfg.commonHeaders() {
            headerDict = headerDict ?? Dictionary()
            headerDict?.merge(p, uniquingKeysWith: { old, new in
                return new
            })
        }
        do {
            let asUrl = try url.asURL()
            let method: HTTPMethod = !isGet ? .post : .get
            let request = AF.upload(multipartFormData: { formdata in
                // 1.参数 parameters
                if let parameters = cfg.commonParams() {
                    for p in parameters {
                        formdata.append(p.value.data(using: .utf8)!, withName: p.key)
                    }
                }
                // 2.数据 datas
                for (key,value) in files{
                    formdata.append(value, withName: key, mimeType: mimeType)
                }

            }, to: asUrl, method:method, headers: header(headerDict))
                
            request.responseJSON { response in
                LSBaseNet.remove(request.id.uuidString) //请求完成，清除请求记录
                LSBaseNet.requestFinish(config: cfg,response: response, success: success, failure: failure)
            }
            request.uploadProgress(queue: .main) { progress in
                if let pg = progressClosure{
                    pg(progress.fractionCompleted)
                }
            }
            LSBaseNet.add(request)
            return request.id.uuidString
        }catch {
            
        }
        return nil
    }
    /**
     @brief 下载文件请求
     @param apiName 接口名， 可以为完整的url地址，非完整url自动拼接baseurlStr
     @param isPost 是否为post请求
     @param resumeData 断点续传数据， 本地上传已下载的数据. 此参数又值是， 其他非闭包参数无需传值
     @return 返回请求唯一标识, 需要持有请求时使用
     @author rf/2021-06-28
     */
    @discardableResult
    public mutating func download(_ apiName:String, params:[String: String]? = nil, headers:[String: String]? = nil, isPost:Bool = false, resumeData:Data? = nil, success:((String?, Any)->Void)?=nil, failure:((String?, Dictionary<String,Any>)->Void)?=nil, progressClosure: ((Double)->Void)? ) -> String?{
//        let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory)
        guard let url = URL(string: url(apiName))  else {
            fatalError("LSBaseNet下载地址异常")
        }
        guard let cfg = config else {
            fatalError("LSBaseNet网络配置未完成，无法使用")
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
        do {
            let asUrl = try url.asURL()
            let method: HTTPMethod = isPost ? .post : .get
            let request: DownloadRequest
            if let data = resumeData {
                request = AF.download(resumingWith: data)
            }else{
                request = AF.download(asUrl,method:method, parameters:paramsDict, headers:  header(headerDict), to: nil)
            }
            
            request.responseData { response in
                LSBaseNet.remove(request.id.uuidString) //请求完成，清除请求记录
                LSBaseNet.downloadFinish(config: cfg, response: response, success: success, failure: failure)
            }
            request.downloadProgress(queue: .main) { progress in
                if let pg = progressClosure{
                    pg(progress.fractionCompleted)
                }
            }
            LSBaseNet.add(request)
            return request.id.uuidString
        }catch {
            
        }
        return nil
    }
    
    /**
     @brief 请求
     @discussion 当带params时， encoder使用URLEncodedFormParameterEncoder.default。经验证，使用JSONParameterEncoder在带参数时请求异常
     */
    fileprivate mutating func request(_ apiName:String, method:HTTPMethod,params:[String: String]? = nil, headers:[String: String]? = nil, encoder: ParameterEncoder, filter:RequestInterceptor? = nil, success:((String?, Any)->Void)?=nil, failure:((String?, Dictionary<String,Any>)->Void)?=nil) -> String? {
        guard let cfg = config else {
            fatalError("LSBaseNet网络配置未完成，无法使用")
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
        let request: DataRequest = AF.request(url(apiName), method:method, parameters: paramsDict, encoder: paramEncoder , headers: header(headerDict), interceptor:cfg.bRetry ? CustomRequestInterceptor(config: cfg) : nil, requestModifier: nil)
        //JSONParameterEncoder.default
        if cfg.bEncrypt {  //返回格式定义为字符串
            request.responseString { response in
                LSBaseNet.remove(request.id.uuidString) //请求完成，清除请求记录
                LSBaseNet.requestFinish(config: cfg,response: response, success: success, failure: failure)
            }
        }else{  //返回json
            request.responseJSON { response in
                LSBaseNet.remove(request.id.uuidString) //请求完成，清除请求记录
                LSBaseNet.requestFinish(config: cfg,response: response, success: success, failure: failure)
            }
        }
        LSBaseNet.add(request)
        return request.id.uuidString
    }
    
}
//MARK: 网络请求对象编辑
extension LSBaseNet{
    /**
     @brief 取消所有网络请求.  比如被踢或其他报错，进入登录页同时取消所有可能未完成的请求
     @author rf/2021-06-28
     */
    public func cancelAll(){
        AF.cancelAllRequests()
    }
    /**
     @brief 根据requestId取消请求
     @author rf/2021-06-28
     */
    public mutating func cancel(_ rid: String){
        if let request = LSBaseNet.getRequest(rid) {
            if request.isCancelled {
                return
            }
            request.cancel()
        }
    }
    /**
     @brief 根据requestId暂停请求
     @author rf/2021-06-28
     */
    public mutating func suspend(_ rid: String){
        if let request = LSBaseNet.getRequest(rid) {
            if request.isSuspended {
                return
            }
            request.suspend()
        }
    }
    /**
     @brief 根据requestId恢复请求
     @author rf/2021-06-28
     */
    public mutating func resume(_ rid: String){
        if let request = LSBaseNet.getRequest(rid) {
            if request.isResumed {
                return
            }
            request.resume()
        }
    }
    //根据id获取当前请求
    fileprivate static func getRequest(_ rid: String) -> Request?{
        defer {
            sema.signal()
        }
        sema.wait()
        let request: Request?
        request = requestDict[rid]
        return request
        
    }
    //保存当前请求
    fileprivate static func add(_ request:Request){
        sema.wait()
        requestDict.updateValue(request, forKey: request.id.uuidString)
        sema.signal()
    }
    fileprivate static func remove(_ rid: String){
        defer {
            sema.signal()
        }
        sema.wait()
        requestDict.removeValue(forKey: rid)
    }
}
//MARK: 网络请求接口传参处理
extension LSBaseNet {
    /**
     @brief 请求结果处理
     @param response 返回内容。
     @author rf/2021-06-28
     */
    fileprivate static func requestFinish<T>(config: LSConfigNetProtocol,response:AFDataResponse<T>, success:((String?, Any)->Void)?=nil, failure:((String?, Dictionary<String,Any>)->Void)?=nil) {
        debugPrint(response)
        
        switch response.result {
            case .failure(let error):
                if let fail = failure {
                    fail(response.request?.url?.absoluteString, ["code": error.responseCode ?? -1, "msg": error.localizedDescription
                    ])
                }
            case .success(let result):
                var dict = [String:Any]()
                
                if let res = result as? String { //返回结果为加密字符串处理
                    let encryptStr: String = res
                    dict = config.commonDecrypt(encryptStr)
                }else if let res = result as? Dictionary<String, Any> {
                    dict = res
                }
                
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
    /**
     @brief 下载结果处理
     @param response 返回内容。
     @author rf/2021-06-28
     */
    fileprivate static func downloadFinish<T>(config: LSConfigNetProtocol,response:AFDownloadResponse<T>, success:((String?, Data)->Void)?=nil, failure:((String?, Dictionary<String,Any>)->Void)?=nil) {
        debugPrint(response)
        switch response.result {
            case .failure(let error):
                if let fail = failure {
                    fail(response.request?.url?.absoluteString, ["code": error.responseCode ?? -1, "msg": error.localizedDescription
                    ])
                }
            case .success(let result):
                if let res = result as? Data {
                    if let succ = success {
                        succ(response.request?.url?.absoluteString, res)
                    }
                }else{
                    if let fail = failure {
                        fail(response.request?.url?.absoluteString, ["code": -1 , "msg": "未知错误"
                        ])
                    }
                }
                
            return
        }
    }
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

