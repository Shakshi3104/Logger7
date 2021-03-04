//
//  WatchSensorData.swift
//  LoggerWatchPods WatchKit Extension
//
//  Created by Satoshi on 2020/10/30.
//

import Foundation

// 文字列を長さで分割するextension
extension String {
    func components(withLength length: Int) -> [String] {
        return stride(from: 0, to: self.count, by: length).map {
            let start = self.index(self.startIndex, offsetBy: $0)
            let end = self.index(start, offsetBy: length, limitedBy: self.endIndex) ?? self.endIndex
            return String(self[start..<end])
        }
    }
}

struct SensorData {
    var accelerometerData: String
    var gyroscopeData: String
    
    // 1秒毎にiPhoneに送信するデータ
    private var accelerometerDataSec: String
    private var gyroscopeDataSec: String
    
    
    // iPhone側にデータを送信するため
    var connector = PhoneConnector()
    
    init() {
        self.accelerometerData = ""
        self.gyroscopeData = ""
        self.accelerometerDataSec = ""
        self.gyroscopeDataSec = ""
    }
    
    mutating func append(time: String, x: Double, y: Double, z: Double, sensorType: SensorType) {
        var line = time + ","
        line.append(String(x) + ",")
        line.append(String(y) + ",")
        line.append(String(z) + "\n")
        
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
        self.accelerometerData = ""
        self.gyroscopeData = ""
        
        self.accelerometerDataSec = ""
        self.gyroscopeDataSec = ""
    }
    
    // iPhone側にcsv形式のStringを送信する
    mutating func sendAccelerometerData() {
//        print("Size: \(self.accelerometerDataSec.lengthOfBytes(using: String.Encoding.utf8)) byte")
        
        if self.connector.send(key: "ACC_DATA", value: self.accelerometerDataSec) {
            self.accelerometerDataSec = ""
        }
    }
    
    mutating func sendGyroscopeData() {
//        print("Size: \(self.gyroscopeDataSec.lengthOfBytes(using: String.Encoding.utf8)) byte")
        
        if self.connector.send(key: "GYR_DATA", value: self.gyroscopeDataSec) {
            self.gyroscopeDataSec = ""
        }
    }
    
    mutating func sendDataAfterStop(splitSize: Int) {
        print("All Size: \(self.accelerometerData.lengthOfBytes(using: String.Encoding.utf8)) byte")
        
        let accComponents = self.accelerometerData.components(withLength: splitSize * 1024)
        print(accComponents.count)
        accComponents.forEach { (component) in
            print("Size: \(component.lengthOfBytes(using: String.Encoding.utf8)) byte")
            if self.connector.send(key: "ACC_ALL", value: component) {
                print("Success")
            }
        }
        
        print("All Size: \(self.gyroscopeData.lengthOfBytes(using: String.Encoding.utf8)) byte")
        
        let gyrComponents = self.gyroscopeData.components(withLength: splitSize * 1024)
        print(gyrComponents.count)
        gyrComponents.forEach { (component) in
            print("Size: \(component.lengthOfBytes(using: String.Encoding.utf8)) byte")
            if self.connector.send(key: "GYR_ALL", value: component) {
                print("Success")
            }
        }
        
        print("All data sended")
    }
}
