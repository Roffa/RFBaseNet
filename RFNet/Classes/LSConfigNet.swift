//
//  LSConfigNet.swift
//  RFNet
//
//  Created by zrf on 2021/6/25.
//

import Foundation

//MARK: 专属网络配置类
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
        return nil  //默认无公共参数
    }
    public func commonHeaders()->[String:String]?{
        return nil
    }
    //加解密后数据。 当bEncrypt=true时需要实现下面两方法
    public func commonEncrypt(_ paramStr: String?)->Data? {
        return nil
    }
    public func commonDecrypt(_ result: String?)->[String:Any]{
        return Dictionary()
    }
}
