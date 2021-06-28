//
//  LSReachabilityNet.swift
//  RFNet
//
//  Created by zrf on 2021/6/28.
//

import Foundation
import Alamofire

public extension Notification.Name {
    /// 网络状态切换
    static let LSNetStatusDidChangeNotification = Notification.Name("LSNetStatusDidChangeNotification")
}
 
public enum LSNetworkStatus {
    /// It is unknown whether the network is reachable.
    case unknown
    /// The network is not reachable.
    case notReachable
   /// The connection type is either over Ethernet or WiFi.
    case wifi
    /// The connection type is a cellular connection.
    case phone
    
}
public class LSNetworkStatusManager {
    public static let share = LSNetworkStatusManager()
    private let manager = NetworkReachabilityManager.default!
    private init() { }
    
   
    /**
     @brief 当前网络是否可用. wifi或手机信息可用
     */
    public var isReachable:Bool {
        return manager.isReachable
    }
    public var status:LSNetworkStatus {
        switch manager.status {
        case .unknown:
            return .unknown
        case .reachable(.cellular):
            return .phone
        case .reachable(.ethernetOrWiFi):
            return .wifi
        default:
            return .notReachable
        }
    }
    func startListening() {
        manager.startListening(onUpdatePerforming: { [unowned self] (s) in
            NotificationCenter.default.post(name: .LSNetStatusDidChangeNotification, object: status)
        })
    }
}
