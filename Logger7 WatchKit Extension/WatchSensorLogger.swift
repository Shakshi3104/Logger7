//
//  WatchSensorLogger.swift
//  LoggerWatchPods WatchKit Extension
//
//  Created by Satoshi on 2020/10/30.
//

import Foundation
import CoreMotion
import Combine
import WatchKit


class WatchSensorManager: NSObject, ObservableObject, WKExtendedRuntimeSessionDelegate {
    
    var motionManager: CMMotionManager?
    var data = SensorData()
    
    @Published var accX = 0.0
    @Published var accY = 0.0
    @Published var accZ = 0.0
    @Published var gyrX = 0.0
    @Published var gyrY = 0.0
    @Published var gyrZ = 0.0
    
    private var samplingFrequency = 50.0
    
    var timer = Timer()
    
    var session: WKExtendedRuntimeSession!
    
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
        let timestamp = getTimestamp()
        self.data.append(time: timestamp, x: self.accX, y: self.accY, z: self.accZ, sensorType: .watchAccelerometer)
        self.data.append(time: timestamp, x: self.gyrX, y: self.gyrY, z: self.gyrZ, sensorType: .watchGyroscope)
        
        print("Watch: \(timestamp), acc (\(self.accX), \(self.accY), \(self.accZ)), gyr (\(self.gyrX), \(self.gyrY), \(self.gyrZ))")
        
//        self.data.sendAccelerometerData()
//        self.data.sendGyroscopeData()
    }
    
    func startUpdate(_ freq: Double) {
        if motionManager!.isAccelerometerAvailable {
            motionManager?.startAccelerometerUpdates()
        }
        
        // Gyroscopeの生データの代わりにDeviceMotionのrotationRateを取得する
        if motionManager!.isDeviceMotionAvailable {
            motionManager?.startDeviceMotionUpdates()
        }
        
        self.samplingFrequency = freq
        
        // Extended Runtime Session
        self.session = WKExtendedRuntimeSession()
        self.session.delegate = self
        self.session.start()
        
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
        
        // 約40KBごとに送る
        self.data.sendDataAfterStop(splitSize: 40)
        self.data.reset()
 
        self.session.invalidate()
    }
    
    // For Extended Runtime Session
    func extendedRuntimeSession(_ extendedRuntimeSession: WKExtendedRuntimeSession, didInvalidateWith reason: WKExtendedRuntimeSessionInvalidationReason, error: Error?) {
        let timestamp = getTimestamp()
        print("\(timestamp): didInvalidateWith reason=\(reason)")
    }
    
    func extendedRuntimeSessionDidStart(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        let timestamp = getTimestamp()
        print("\(timestamp): extendedRuntimeSessionDidStart")
    }
    
    func extendedRuntimeSessionWillExpire(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        let timestamp = getTimestamp()
        print("\(timestamp): extendedRuntimeSessionWillExpire")
    }
}
