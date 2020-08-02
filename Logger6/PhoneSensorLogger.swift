//
//  PhoneSensorLogger.swift
//  Logger6
//
//  Created by MacBook Pro on 2020/08/02.
//  Copyright © 2020 MacBook Pro. All rights reserved.
//


import Foundation
import CoreMotion
import Combine

class SensorLogManager: NSObject, ObservableObject {
    var motionManager: CMMotionManager?
    var logger = SensorLogger()
    
    @Published var accX = 0.0
    @Published var accY = 0.0
    @Published var accZ = 0.0
    @Published var gyrX = 0.0
    @Published var gyrY = 0.0
    @Published var gyrZ = 0.0
    @Published var magX = 0.0
    @Published var magY = 0.0
    @Published var magZ = 0.0
    
    @Published var accXArray = [0.0]
    @Published var accYArray = [0.0]
    @Published var accZArray = [0.0]
    @Published var gyrXArray = [0.0]
    @Published var gyrYArray = [0.0]
    @Published var gyrZArray = [0.0]
    
    var timer = Timer()
    
    override init() {
        super.init()
        self.motionManager = CMMotionManager()
    }
    
    @objc private func startLogSensor() {
        let suffixLength = 64
        
        if let data = motionManager?.accelerometerData {
            let x = data.acceleration.x
            let y = data.acceleration.y
            let z = data.acceleration.z
            
            self.accX = x
            self.accY = y
            self.accZ = z
            
            // グラフ表示用
            self.accXArray.append(x)
            self.accXArray = self.accXArray.suffix(suffixLength)
            self.accYArray.append(y)
            self.accYArray = self.accYArray.suffix(suffixLength)
            self.accZArray.append(z)
            self.accZArray = self.accZArray.suffix(suffixLength)
        }
        else {
            self.accX = Double.nan
            self.accY = Double.nan
            self.accZ = Double.nan
        }
        
        if let data = motionManager?.gyroData {
            let x = data.rotationRate.x
            let y = data.rotationRate.y
            let z = data.rotationRate.z
            
            self.gyrX = x
            self.gyrY = y
            self.gyrZ = z
            
            // グラフ表示用
            self.gyrXArray.append(x)
            self.gyrXArray = self.gyrXArray.suffix(suffixLength)
            self.gyrYArray.append(y)
            self.gyrYArray = self.gyrYArray.suffix(suffixLength)
            self.gyrZArray.append(z)
            self.gyrZArray = self.gyrZArray.suffix(suffixLength)
        }
        else {
            self.gyrX = Double.nan
            self.gyrY = Double.nan
            self.gyrZ = Double.nan
        }
        
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
        
        // センサデータを記録する
        let timestamp = self.logger.getTimestamp()
        self.logger.logAccelerometerData(time: timestamp, x: self.accX, y: self.accY, z: self.accZ)
        self.logger.logGyroscopeData(time: timestamp, x: self.gyrX, y: self.gyrY, z: self.gyrZ)
        self.logger.logMagnetometerData(time: timestamp, x: self.magX, y: self.magY, z: self.magZ)
        
        print(timestamp + ", \(self.accX), \(self.accY), \(self.accZ)")
        
    }
    
    func startUpdate(_ freq: Double) {
        if motionManager!.isAccelerometerAvailable {
            motionManager?.startAccelerometerUpdates()
        }
        
        if motionManager!.isGyroAvailable {
            motionManager?.startGyroUpdates()
        }
        
        if motionManager!.isMagnetometerAvailable {
            motionManager?.startMagnetometerUpdates()
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
        
        if motionManager!.isAccelerometerActive {
            motionManager?.stopAccelerometerUpdates()
        }
        
        if motionManager!.isGyroActive {
            motionManager?.stopGyroUpdates()
        }
        
        if motionManager!.isMagnetometerActive {
            motionManager?.stopMagnetometerUpdates()
        }
    }
    
}


class SensorLogger {
    var accelerometerData : String
    var gyroscopeData : String
    var magnetometerData : String
    
    public init() {
        let column = "time,x,y,z\n"
        self.accelerometerData = column
        self.gyroscopeData = column
        self.magnetometerData = column
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
    }
    
    func logGyroscopeData(time: String, x: Double, y: Double, z: Double) {
        var line = time + ","
        line.append(contentsOf: String(x) + ",")
        line.append(contentsOf: String(y) + ",")
        line.append(contentsOf: String(z) + "\n")
        
        self.gyroscopeData.append(contentsOf: line)
    }
    
    func logMagnetometerData(time: String, x: Double, y: Double, z: Double) {
        var line = time + ","
        line.append(contentsOf: String(x) + ",")
        line.append(contentsOf: String(y) + ",")
        line.append(contentsOf: String(z) + "\n")
        
        self.magnetometerData.append(contentsOf: line)
    }
    
    // 保存したファイルパスを取得する
    func getDataURLs(label: String, subject: String) -> [URL] {
        let format = DateFormatter()
        format.dateFormat = "yyyyMMddHHmmss"
        let time = format.string(from: Date())
        
        /* 一時ファイルを保存する場所 */
        let tmppath = NSHomeDirectory() + "/tmp"
        
        let apd = "\(time)_\(label)_\(subject)" // 付加する文字列(時間+ラベル+ユーザ名)
        // ファイル名を生成
        let accelerometerFilepath = tmppath + "/accelermeter_\(apd).csv"
        let gyroFilepath = tmppath + "/gyroscope_\(apd).csv"
        let magnetFilepath = tmppath + "/magnetometer_\(apd).csv"
        
        // ファイルを書き出す
        do {
            try self.accelerometerData.write(toFile: accelerometerFilepath, atomically: true, encoding: String.Encoding.utf8)
            try self.gyroscopeData.write(toFile: gyroFilepath, atomically: true, encoding: String.Encoding.utf8)
            try self.magnetometerData.write(toFile: magnetFilepath, atomically: true, encoding: String.Encoding.utf8)
        }
        catch let error as NSError{
            print("Failure to Write File\n\(error)")
        }
        
        /* 書き出したcsvファイルの場所を取得 */
        var urls = [URL]()
        urls.append(URL(fileURLWithPath: accelerometerFilepath))
        urls.append(URL(fileURLWithPath: gyroFilepath))
        urls.append(URL(fileURLWithPath: magnetFilepath))
        
        // データをリセットする
        self.resetData()
        
        return urls
    }
    
    // データをリセットする
    func resetData() {
        let column = "time,x,y,z\n"
        self.accelerometerData = column
        self.gyroscopeData = column
        self.magnetometerData = column
    }
}
