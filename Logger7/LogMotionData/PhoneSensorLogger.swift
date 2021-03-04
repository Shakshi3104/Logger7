//
//  PhoneSensorLogger.swift
//  LoggerWatchPods
//
//  Created by Satoshi on 2020/10/30.
//

import Foundation
import CoreMotion
import Combine


@available(iOS 14.0, *)
class PhoneSensorManager: NSObject, ObservableObject {
    var motionManager: CMMotionManager?
    var headphoneMotionManager: CMHeadphoneMotionManager?
    
    private var sensorDataManager = SensorDataManager.shared
    
    // iPhone
    @Published var accX = 0.0
    @Published var accY = 0.0
    @Published var accZ = 0.0
    @Published var gyrX = 0.0
    @Published var gyrY = 0.0
    @Published var gyrZ = 0.0
    @Published var magX = 0.0
    @Published var magY = 0.0
    @Published var magZ = 0.0
    
    // Headphone
    @Published var headAccX = 0.0
    @Published var headAccY = 0.0
    @Published var headAccZ = 0.0
    @Published var headGyrX = 0.0
    @Published var headGyrY = 0.0
    @Published var headGyrZ = 0.0
    
    var timer = Timer()
    
    override init() {
        super.init()
        self.motionManager = CMMotionManager()
        self.headphoneMotionManager = CMHeadphoneMotionManager()
    }
    
    @objc private func startLogSensor() {
        let timestamp = getTimestamp()
        
        // iPhone
        /// Accelerometer
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
        
        /// Gyroscope
        if let data = motionManager?.gyroData {
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
        
        /// Magnetometer
        if let data = motionManager?.magnetometerData {
            let x = data.magneticField.x
            let y = data.magneticField.y
            let z = data.magneticField.z
            
            self.magX = x
            self.magY = y
            self.magZ = z
        }
        else {
            self.magX = Double.nan
            self.magY = Double.nan
            self.magZ = Double.nan
        }
        
        self.sensorDataManager.append(time: timestamp, x: self.accX, y: self.accY, z: self.accZ, sensorType: .phoneAccelerometer)
        self.sensorDataManager.append(time: timestamp, x: self.gyrX, y: self.gyrY, z: self.gyrZ, sensorType: .phoneGyroscope)
        self.sensorDataManager.append(time: timestamp, x: self.magX, y: self.magY, z: self.magZ, sensorType: .phoneMagnetometer)
        
        
        // AirPods Pro
        if let data = self.headphoneMotionManager?.deviceMotion {
            let accX = data.gravity.x + data.userAcceleration.x
            let accY = data.gravity.y + data.userAcceleration.y
            let accZ = data.gravity.z + data.userAcceleration.z
            
            let gyrX = data.rotationRate.x
            let gyrY = data.rotationRate.y
            let gyrZ = data.rotationRate.z
            
            self.headAccX = accX
            self.headAccY = accY
            self.headAccZ = accZ
            self.headGyrX = gyrX
            self.headGyrY = gyrY
            self.headGyrZ = gyrZ
            
            self.sensorDataManager.append(time: timestamp, x: self.headAccX, y: self.headAccY, z: self.headAccZ, sensorType: .headphoneAccelerometer)
            self.sensorDataManager.append(time: timestamp, x: self.headGyrX, y: self.headGyrY, z: self.headGyrZ, sensorType: .headphoneGyroscope)
        }
        else {
            self.headAccX = Double.nan
            self.headAccY = Double.nan
            self.headAccZ = Double.nan
            self.headGyrX = Double.nan
            self.headGyrY = Double.nan
            self.headGyrZ = Double.nan
        }
    }
    
    func startUpdate(_ freq: Double) {
        if self.motionManager!.isAccelerometerAvailable {
            self.motionManager?.startAccelerometerUpdates()
        }
        
        if self.motionManager!.isGyroAvailable {
            self.motionManager?.startGyroUpdates()
        }
        
        if self.motionManager!.isMagnetometerAvailable {
            self.motionManager?.startMagnetometerUpdates()
        }
        
        print("CMHeadphoneMotionManager.isDeviceMotionAvailable: \(self.headphoneMotionManager!.isDeviceMotionAvailable)")
       
        if self.headphoneMotionManager!.isDeviceMotionAvailable {
            self.headphoneMotionManager?.startDeviceMotionUpdates()
        }
    
        
        // プル型でデータ取得
        self.timer = Timer.scheduledTimer(timeInterval: 1.0 / freq,
                           target: self,
                           selector: #selector(self.startLogSensor),
                           userInfo: nil,
                           repeats: true)
        
    }
    
    func stopUpdate() {
        self.timer.invalidate()
        
        if self.motionManager!.isAccelerometerActive {
            self.motionManager?.stopAccelerometerUpdates()
        }
        
        if self.motionManager!.isGyroActive {
            self.motionManager?.stopGyroUpdates()
        }
        
        if self.motionManager!.isMagnetometerActive {
            self.motionManager?.stopMagnetometerUpdates()
        }
        
        if self.headphoneMotionManager!.isDeviceMotionActive {
            self.headphoneMotionManager?.stopDeviceMotionUpdates()
        }
        
    }
    
}
