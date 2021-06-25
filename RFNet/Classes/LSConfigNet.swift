//
//  LSConfigNet.swift
//  RFNet
//
//  Created by zrf on 2021/6/25.
//

import Foundation


public protocol LSConfigNetProtocol {
    var baseUrlStr: String? {get set}
    var bRetry:Bool{get set}   //是否开启失败3次重试。 默认关闭
    var bEncrypt:Bool{get set}  //是否加密传输
    
    func customAdapt(_ urlRequest: URLRequest) -> URLRequest  //bRetry=ture.配置超时、增加header等操作
    
    //由于Alamofire5以上要求传参必须遵循Encodable协议，此处强制要求传参必须为字符串，否则要实现参数对象来适配Codable协议
    func commonParams()->[String:String]?  //公共参数配置
    func commonHeaders()->[String:String]?  //公共Header配置
    func commonEncrypt(_ paramStr: String?)->Data?  //json string参数加密.
    func commonDecrypt(_ result: String?)->[String:Any]  //返回结果解密.
}
extension LSConfigNetProtocol{
    public func commonParams() -> [String:String]? {
        return [
            "network" : "0",
            "iosAccid" : "C6A10D0CC92D40F78D408D1742AB9E03",
            "accid" : "",
            "projectCode": "scanner",
            "uuid":"C6A10D0CC92D40F78D408D1742AB9E03",
            "isAbroad" : "0",
            "umOid": "27368476ace8cc5be8fdeb632c105219da9a41fb",
            "devicebrand" : "iPhone",
            "ts": String(Int(Date().timeIntervalSince1970)),
            "appver" : "1.4.0",
            "apptypeid" : "100055",
            "os": "iOS",
            "istourist": "0",
            "obatchid" : "1628d0bccfafa6c0",
            "timezone" : "8",
            "deviceid":"5E927A9B-71CD-4C95-9605-27F708D65A35",
            "osversion" : "14.4.2",
            "appqid" : "appstore210624",
            "appverint" : "010400",
            "country" : "徐汇区",
            "province" : "上海市",
            "device" : "iPhone 11",
            "appcqid" : "appstore",
            "imei" : "B9C09211-E9A9-4346-A91B-87CD01A4A788",
            "pixel" : "828*1792",
            "userinfo" : "{\"usertype\":\"null\",\"sex\":\"null\",\"bd\":\"null\",\"regts\":\"null\",\"lastinstall\":\"1624498054\"}"
        ]
    }
    public func commonHeaders()->[String:String]?{
        return [
            "Content-Type" : "application/x-www-form-urlencoded; charset=utf-8",
            "deviceId" : "C6A10D0CC92D40F78D408D1742AB9E03",
            "uuid" : "C6A10D0CC92D40F78D408D1742AB9E03",
            "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpbWdVcmwiOiJodHRwczovL2Nkbi1zY2FubmVyLmxhbnNoYW4uY29tL2hlYWQvZGVmYXVsdC5wbmciLCJwYXNzSWQiOiJmYTBkMjRlNGZlNjI0NTU2OTFjNTdiYjU1NTEzOTE0YSIsIm5hbWUiOiLnlKjmiLcxMzIqKioqODMyOSIsImFjY0lkIjoiMTYzNzg1MTkxMGU1MTYxYjFsdE05cyIsImV4cCI6MTYzMTYxMjIwOCwiaWF0IjoxNjIzODM2MjA4fQ.GrWFrel4smXzdmkg6OTjKfOtKMnnXJhbNSJskfK46D0"
        ]
    }
    public func commonEncrypt(_ paramStr: String?)->Data? {
        return nil
    }
    public func commonDecrypt(_ result: String?)->[String:Any]{
        return Dictionary()
    }
}
