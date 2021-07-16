//
//  ViewController.swift
//  RFNet
//
//  Created by zrf on 06/24/2021.
//  Copyright (c) 2021 zrf. All rights reserved.
//

import UIKit
import RFNet

struct ConfigNetDemo: LSConfigNetProtocol{
    var bEncrypt: Bool = true
    var baseUrlStr: String? = "https://test-api2-office.lanshan.com"
    var bRetry: Bool = false
    
    func customAdapt(_ urlRequest: URLRequest) -> URLRequest{
        var request = urlRequest
        request.timeoutInterval = 40
        return request
    }
    
}

class ViewController: UIViewController {
    var config = ConfigNetDemo()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        LSBaseNet.shared.config = config
        LSBaseNet.shared.post("/file/list", params: ["uniqueCode": "315BBF99953645189E86604310D5543A", "token":"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpbWdVcmwiOiJodHRwczovL2Nkbi1zY2FubmVyLmxhbnNoYW4uY29tL2hlYWQvZGVmYXVsdC5wbmciLCJwYXNzSWQiOiJmYTBkMjRlNGZlNjI0NTU2OTFjNTdiYjU1NTEzOTE0YSIsIm5hbWUiOiLnlKjmiLcxMzIqKioqODMyOSIsImFjY0lkIjoiMTYzNzg1MTkxMGU1MTYxYjFsdE05cyIsImV4cCI6MTYzMTYxMjIwOCwiaWF0IjoxNjIzODM2MjA4fQ.GrWFrel4smXzdmkg6OTjKfOtKMnnXJhbNSJskfK46D0"], success:{ url, result in

        }){ url, result in

        }
        
        LSBaseNet.shared.download("https://cdn-office.lanshan.com/office_document_test/teamwork/35ac23ff66a3471e89ed0bb0c242a0ff/D3EEF9364CB643DCBF357698928A817D.docx") { url, result in
            
        } failure: { url, result in
            
        } progressClosure: { f in
            
        }
        LSBaseNet.shared.upload("http://api.laravel.com/user/file", files: ["file": "上传文件".data(using: .utf8)!]) { url, result in
            
        } failure: { url, result in
            
        } progressClosure: { f in
            
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(networkChanged(_:)), name: .LSNetStatusDidChangeNotification, object: nil)
    }
    @objc func networkChanged(_ notif: Notification) -> Void {
        
        if let status = (notif.object as? LSNetworkStatus) {
            if status == .phone || status == .wifi {
                print("当前网络状态正常")
            }else{
                print("当前网络状态异常")
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

