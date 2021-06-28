# RFNet

[![CI Status](https://img.shields.io/travis/zrf/RFNet.svg?style=flat)](https://travis-ci.org/zrf/RFNet)
[![Version](https://img.shields.io/cocoapods/v/RFNet.svg?style=flat)](https://cocoapods.org/pods/RFNet)
[![License](https://img.shields.io/cocoapods/l/RFNet.svg?style=flat)](https://cocoapods.org/pods/RFNet)
[![Platform](https://img.shields.io/cocoapods/p/RFNet.svg?style=flat)](https://cocoapods.org/pods/RFNet)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

post/get接口默认返回格式为dictionary
```
//配置网络. 加解密等都在此类里进行配置，使用时更轻便
struct ConfigNetDemo: LSConfigNetProtocol{
    var bEncrypt: Bool = true
    var baseUrlStr: String? = "http://test-b-passport.sdqcloud.com"
    var bRetry: Bool = false
    
    func customAdapt(_ urlRequest: URLRequest) -> URLRequest{
        var request = urlRequest
        request.timeoutInterval = 40
        return request
    }
    
}
```
调用
```
var config = ConfigNetDemo()
LSBaseNet.shared.config = config
//post请求
LSBaseNet.shared.post("/sms/send_code", params: ["tel":"18721791941", "type":"5"], success:{ url, result in
    
}){ url, result in
    
}
//下载请求
LSBaseNet.shared.download("https://cdn-office.lanshan.com/office_document_test/teamwork/35ac23ff66a3471e89ed0bb0c242a0ff/D3EEF9364CB643DCBF357698928A817D.docx") { url, result in
    
} failure: { url, result in
    
} progressClosure: { f in
    
}
//上传文件
LSBaseNet.shared.upload("http://api.laravel.com/user/file", files: ["file": "上传文件".data(using: .utf8)!]) { url, result in
    
} failure: { url, result in
    
} progressClosure: { f in
    
}
```
网络状态监控
```
NotificationCenter.default.addObserver(self, selector: #selector(networkChanged(_:)), name: .LSNetStatusDidChangeNotification, object: nil)

@objc func networkChanged(_ notif: Notification) -> Void {
    
    if let status = (notif.object as? LSNetworkStatus) {
        if status == .phone || status == .wifi {
            print("当前网络状态正常")
        }else{
            print("当前网络状态异常")
        }
    }
}
```

## Requirements

## Installation

RFNet is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'RFNet'
```

## Author

zrf, roffa@qq.com

## License

RFNet is available under the MIT license. See the LICENSE file for more info.
