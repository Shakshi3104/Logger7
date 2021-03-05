//
//  WatchConnector.swift
//  LoggerWatchPods
//
//  Created by Satoshi on 2020/10/30.
//

import Foundation
import UIKit
import WatchConnectivity

class WatchConnector: NSObject, ObservableObject, WCSessionDelegate {
    
    var sensorDataManager = SensorDataManager.shared
    
    // Sensor values from Apple Watch
    @Published var accX = 0.0
    @Published var accY = 0.0
    @Published var accZ = 0.0
    @Published var gyrX = 0.0
    @Published var gyrY = 0.0
    @Published var gyrZ = 0.0
    
    @Published var isReceivedAccData = false
    @Published var isReceivedGyrData = false
    
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
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("sessionDidBecomeInactive")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("sessionDidDeactivate")
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {

        DispatchQueue.main.async {
            // iPhone appで表示する用
            if let accData = message["ACC_DATA"] as? String {

                if accData.count != 0 {
                    // iPhone上で表示する
                    let accDataDouble = self.stringToDouble(data: accData)
                    self.accX = accDataDouble[0]
                    self.accY = accDataDouble[1]
                    self.accZ = accDataDouble[2]
                }
            }
            
            if let gyrData = message["GYR_DATA"] as? String {
                
                if gyrData.count != 0 {
                    let gyrDataDouble = self.stringToDouble(data: gyrData)
                    self.gyrX = gyrDataDouble[0]
                    self.gyrY = gyrDataDouble[1]
                    self.gyrZ = gyrDataDouble[2]
                }
            }
            
            // データ保存用
            if let accAllData = message["ACC_ALL"] as? String {
                self.sensorDataManager.append(line: accAllData, sensorType: .watchAccelerometer)
                self.isReceivedAccData = true
                print("Received")
            }
            
            if let gyrAllData = message["GYR_ALL"] as? String {
                self.sensorDataManager.append(line: gyrAllData, sensorType: .watchGyroscope)
                self.isReceivedGyrData = true
                print("Received")
            }
        }
    }
    
    // Apple Watchから送られてくるStringをDoubleのxyzに分解する
    private func stringToDouble(data: String) -> [Double] {
        // 改行コードを置き換える
        let dataNoLF = data.replacingOccurrences(of: "\n", with: "")
        // カンマ区切り
        let array = dataNoLF.components(separatedBy: ",")
        
        // String to Double
        // Nil Coalescing Operator
        let x = Double(array[1]) ?? Double.nan
        let y = Double(array[2]) ?? Double.nan
        let z = Double(array[3]) ?? Double.nan
        
        let dataDouble = [x, y, z]
        
        return dataDouble
    }
}
