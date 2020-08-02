//
//  PhoneConnector.swift
//  Logger6 WatchKit Extension
//
//  Created by MacBook Pro on 2020/08/02.
//  Copyright © 2020 MacBook Pro. All rights reserved.
//

import Foundation
import UIKit
import WatchConnectivity

class PhoneConnector: NSObject, ObservableObject, WCSessionDelegate {
    
    override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("activationDidCompleteWith state = \(activationState.rawValue)")
    }
    
    func send(key: String, value: Any) -> Bool {
        var isSuccess = false
        
        if WCSession.default.isReachable {
            WCSession.default.sendMessage([key: value], replyHandler: nil) { error in
                print(error)
                isSuccess = false
            }
            
            isSuccess = true
        }
        
        return isSuccess
    }
    
}
