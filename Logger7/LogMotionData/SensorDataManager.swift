//
//  SensorDataManager.swift
//  Logger7
//
//  Created by Satoshi on 2021/03/04.
//  Copyright © 2021 MacBook Pro. All rights reserved.
//

import Foundation
import Combine

enum DeviceType: String {
    case phone = "iphone"
    case headphone = "airpodspro"
    case watch = "applewatch"
}

struct SensorDataRecord: Identifiable {
    var id = UUID()
    
    var timestamp: String
    var urls: [URL]
    var deviceTypes: [DeviceType]
}

class SensorDataManager: ObservableObject {
    static var shared = SensorDataManager()
    
    private var phoneData = SensorData()
    private var watchData = WatchSensorData()
    
    @Published var storedData = [SensorDataRecord]()
    
    func append(time: String, x: Double, y: Double, z: Double, sensorType: SensorType) {
        switch sensorType {
        case .phoneAccelerometer, .phoneGyroscope, .phoneMagnetometer, .headphoneAccelerometer, .headphoneGyroscope:
            self.phoneData.append(time: time, x: x, y: y, z: z, sensorType: sensorType)
        default:
            print("No data of \(sensorType) is available.")
        }
    }
    
    func append(line: String, sensorType: SensorType) {
        switch sensorType {
        case .watchAccelerometer, .watchGyroscope:
            self.watchData.append(line: line, sensorType: sensorType)
        default:
            print("No data of \(sensorType) is available.")
        }
    }
    
    func getURLs(label: String, subject: String) -> SensorDataRecord {
        let phoneRecord: SensorDataRecord = self.phoneData.getURLs(label: label, subject: subject)
        let watchRecord: SensorDataRecord? = self.watchData.getDataURLs(label: label, subject: subject)
        
        let urls = phoneRecord.urls + (watchRecord?.urls ?? [URL]())
        let deviceTypes = phoneRecord.deviceTypes + (watchRecord?.deviceTypes ?? [DeviceType]())
        let time = phoneRecord.timestamp
        
        print(deviceTypes)
        
        let record = SensorDataRecord(timestamp: time, urls: urls, deviceTypes: deviceTypes)
        
        // デバイスの種類が1個以上ならURLを記録する
        if record.deviceTypes.count > 0 {
            self.storedData.append(record)
        }
        print(storedData.count)
        
        return record
    }
    
    func getURLs(label: String, subject: String) -> [URL] {
        let record: SensorDataRecord = getURLs(label: label, subject: subject)
        
        // recordのurlsが空の場合は最新のデータを返す
        if record.urls.count == 0 {
            // storedDataが空の場合は空のリストを返す
            if storedData.count == 0 {
                return [URL]()
            }
            
            let recordLast = storedData.last!
            return recordLast.urls
        }
        
        return record.urls
    }
}
