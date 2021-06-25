# RFNet

[![CI Status](https://img.shields.io/travis/zrf/RFNet.svg?style=flat)](https://travis-ci.org/zrf/RFNet)
[![Version](https://img.shields.io/cocoapods/v/RFNet.svg?style=flat)](https://cocoapods.org/pods/RFNet)
[![License](https://img.shields.io/cocoapods/l/RFNet.svg?style=flat)](https://cocoapods.org/pods/RFNet)
[![Platform](https://img.shields.io/cocoapods/p/RFNet.svg?style=flat)](https://cocoapods.org/pods/RFNet)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

```
//配置网络. 加解密等都在专类里面进行配置
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
LSBaseNet.shared.post("/sms/send_code", params: ["tel":"18721791941", "type":"5"], success:{ url, result in
    
}){ url, result in
    
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

zrf, zhourongfeng@021.com

## License

RFNet is available under the MIT license. See the LICENSE file for more info.
