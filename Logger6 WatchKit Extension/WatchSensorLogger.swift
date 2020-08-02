//
//  WatchSensorLogger.swift
//  Logger6 WatchKit Extension
//
//  Created by MacBook Pro on 2020/08/02.
//  Copyright © 2020 MacBook Pro. All rights reserved.
//

import Foundation
import CoreMotion
import Combine

class WatchSensorLogManager: NSObject, ObservableObject {
    var motionManager: CMMotionManager?
    var logger = WatchSensorLogger()
    
    @Published var accX = 0.0
    @Published var accY = 0.0
    @Published var accZ = 0.0
    @Published var gyrX = 0.0
    @Published var gyrY = 0.0
    @Published var gyrZ = 0.0
    
    private var samplingFrequency = 50.0
    
    var timer = Timer()
    
    override init() {
        super.init()
        self.motionManager = CMMotionManager()
    }
    
    @objc private func startLogSensor() {
        
        if let data = motionManager?.accelerometerData {
            let x = data.acceleration.x
            let y = data.acceleration.y
            let z = data.acceleration.z
            
            self.accX = x
            self.accY = y
            self.accZ = z
        }
        else {
            self.accX = Double.nan
            self.accY = Double.nan
            self.accZ = Double.nan
        }
        
//        if let data = motionManager?.gyroData {
//            let x = data.rotationRate.x
//            let y = data.rotationRate.y
//            let z = data.rotationRate.z
//
//            self.gyrX = x
//            self.gyrY = y
//            self.gyrZ = z
//        }
//        else {
//            self.gyrX = Double.nan
//            self.gyrY = Double.nan
//            self.gyrZ = Double.nan
//        }
        
        if let data = motionManager?.deviceMotion {
            let x = data.rotationRate.x
            let y = data.rotationRate.y
            let z = data.rotationRate.z
            
            self.gyrX = x
            self.gyrY = y
            self.gyrZ = z
            
        }
        else {
            self.gyrX = Double.nan
            self.gyrY = Double.nan
            self.gyrZ = Double.nan
        }
        
        // センサデータを記録する
        let timestamp = self.logger.getTimestamp()
        self.logger.logAccelerometerData(time: timestamp, x: self.accX, y: self.accY, z: self.accZ)
        self.logger.logGyroscopeData(time: timestamp, x: self.gyrX, y: self.gyrY, z: self.gyrZ)
        
        print("Watch: \(timestamp), acc (\(self.accX), \(self.accY), \(self.accZ)), gyr (\(self.gyrX), \(self.gyrY), \(self.gyrZ))")
        
        // iPhoneに送信
        self.logger.sendAccelerometerData()
        self.logger.sendGyroscopeData()
    }
    
    func startUpdate(_ freq: Double) {
        if motionManager!.isAccelerometerAvailable {
            motionManager?.startAccelerometerUpdates()
        }
        
//        if motionManager!.isGyroAvailable {
//            motionManager?.startGyroUpdates()
//        }
        
        // Gyroscopeの生データの代わりにDeviceMotionのrotationRateを取得する
        if motionManager!.isDeviceMotionAvailable {
            motionManager?.startDeviceMotionUpdates()
        }
        
        self.samplingFrequency = freq
        
        // プル型でデータ取得
        self.timer = Timer.scheduledTimer(timeInterval: 1.0 / freq,
                           target: self,
                           selector: #selector(self.startLogSensor),
                           userInfo: nil,
                           repeats: true)
    }
    
    func stopUpdate() {
        self.timer.invalidate()
        
        if motionManager!.isAccelerometerActive {
            motionManager?.stopAccelerometerUpdates()
        }
        
        if motionManager!.isGyroActive {
            motionManager?.stopGyroUpdates()
        }
        
        self.logger.sendAccelerometerData()
        self.logger.sendGyroscopeData()
    }
}


class WatchSensorLogger {
    var accelerometerData: String
    var gyroscopeData: String
    
    // 1秒毎にiPhoneに送信するデータ
    private var accelerometerDataSec: String
    private var gyroscopeDataSec: String
    
    // iPhone側にデータを送信するため
    var connector = PhoneConnector()
    
    public init() {
        let column = "time,x,y,z\n"
        self.accelerometerData = column
        self.gyroscopeData = column
        self.accelerometerDataSec = ""
        self.gyroscopeDataSec = ""
    }
    
    // タイムスタンプを取得する
    func getTimestamp() -> String {
        let format = DateFormatter()
        format.dateFormat = "yyyy/MM/dd HH:mm:ss.SSS"
        return format.string(from: Date())
    }
    
    /* センサデータを保存する */
    func logAccelerometerData(time: String, x: Double, y: Double, z: Double) {
        var line = time + ","
        line.append(contentsOf: String(x) + ",")
        line.append(contentsOf: String(y) + ",")
        line.append(contentsOf: String(z) + "\n")
        
        self.accelerometerData.append(contentsOf: line)
        self.accelerometerDataSec.append(contentsOf: line)
    }
    
    func logGyroscopeData(time: String, x: Double, y: Double, z: Double) {
        var line = time + ","
        line.append(contentsOf: String(x) + ",")
        line.append(contentsOf: String(y) + ",")
        line.append(contentsOf: String(z) + "\n")
        
        self.gyroscopeData.append(contentsOf: line)
        self.gyroscopeDataSec.append(contentsOf: line)
    }
    
    // データをリセットする
    func resetData() {
        let column = "time,x,y,z\n"
        self.accelerometerData = column
        self.gyroscopeData = column
        
        self.accelerometerDataSec = ""
        self.gyroscopeDataSec = ""
    }
    
    // iPhone側にcsv形式のStringを送信する
    func sendAccelerometerData() {
        print("Size: \(self.accelerometerDataSec.lengthOfBytes(using: String.Encoding.utf8)) byte")
        
        if self.connector.send(key: "ACC_DATA", value: self.accelerometerDataSec) {
            self.accelerometerDataSec = ""
        }
    }
    
    func sendGyroscopeData() {
        print("Size: \(self.gyroscopeDataSec.lengthOfBytes(using: String.Encoding.utf8)) byte")
        
        if self.connector.send(key: "GYR_DATA", value: self.gyroscopeDataSec) {
            self.gyroscopeDataSec = ""
        }
    }
}
