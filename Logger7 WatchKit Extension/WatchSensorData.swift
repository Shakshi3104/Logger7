//
//  WatchSensorData.swift
//  LoggerWatchPods WatchKit Extension
//
//  Created by Satoshi on 2020/10/30.
//

import Foundation


struct SensorData {
    var accelerometerData: String
    var gyroscopeData: String
    
    // 1秒毎にiPhoneに送信するデータ
    private var accelerometerDataSec: String
    private var gyroscopeDataSec: String
    
    private let column = "time,x,y,z\n"
    
    // iPhone側にデータを送信するため
    var connector = PhoneConnector()
    
    init() {
        self.accelerometerData = self.column
        self.gyroscopeData = self.column
        self.accelerometerDataSec = ""
        self.gyroscopeDataSec = ""
    }
    
    mutating func append(time: String, x: Double, y: Double, z: Double, sensorType: SensorType) {
        var line = time + ","
        line.append(String(x) + ",")
        line.append(String(x) + ",")
        line.append(String(x) + "\n")
        
        switch sensorType {
        case .watchAccelerometer:
            self.accelerometerData.append(line)
            self.accelerometerDataSec.append(line)
        case .watchGyroscope:
            self.gyroscopeData.append(line)
            self.gyroscopeDataSec.append(line)
        default:
            print("No data of \(sensorType) is available.")
        }
    }
    
    mutating func reset() {
        self.accelerometerData = self.column
        self.gyroscopeData = self.column
        
        self.accelerometerDataSec = ""
        self.gyroscopeDataSec = ""
    }
    
    // iPhone側にcsv形式のStringを送信する
    mutating func sendAccelerometerData() {
        print("Size: \(self.accelerometerDataSec.lengthOfBytes(using: String.Encoding.utf8)) byte")
        
        if self.connector.send(key: "ACC_DATA", value: self.accelerometerDataSec) {
            self.accelerometerDataSec = ""
        }
    }
    
    mutating func sendGyroscopeData() {
        print("Size: \(self.gyroscopeDataSec.lengthOfBytes(using: String.Encoding.utf8)) byte")
        
        if self.connector.send(key: "GYR_DATA", value: self.gyroscopeDataSec) {
            self.gyroscopeDataSec = ""
        }
    }
    
    mutating func sendDataAfterStop() {
        print("All Size: \(self.accelerometerData.lengthOfBytes(using: String.Encoding.utf8)) byte")
    }
}
