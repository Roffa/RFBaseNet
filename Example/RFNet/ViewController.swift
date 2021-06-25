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
    var baseUrlStr: String? = "http://test-b-passport.sdqcloud.com"
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
        LSBaseNet.shared.post("/sms/send_code", params: ["tel":"18721791941", "type":"5"], success:{ url, result in
            
        }){ url, result in
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

