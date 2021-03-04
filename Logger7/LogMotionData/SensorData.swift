//
//  PhoneSensorData.swift
//  LoggerWatchPods
//
//  Created by Satoshi on 2020/10/30.
//

import Foundation

// CSVファイル用のデータ保持
struct SensorData {
    var accelerometerData: String
    var gyroscopeData: String
    var magnetometerData: String
    
    var headphoneAccelerometerData: String
    var headphoneGyroscopeData: String
    
    private let column = "time,x,y,z\n"
    
    init() {
        self.accelerometerData = self.column
        self.gyroscopeData = self.column
        self.magnetometerData = self.column
        
        self.headphoneAccelerometerData = self.column
        self.headphoneGyroscopeData = self.column
    }
    
    // センサデータを記録する
    mutating func append(time: String, x: Double, y: Double, z: Double, sensorType: SensorType) {
        var line = time + ","
        line.append(String(x) + ",")
        line.append(String(y) + ",")
        line.append(String(z) + "\n")
        
        switch sensorType {
        case .phoneAccelerometer:
            self.accelerometerData.append(line)
        case .phoneGyroscope:
            self.gyroscopeData.append(line)
        case .phoneMagnetometer:
            self.magnetometerData.append(line)
        case .headphoneAccelerometer:
            self.headphoneAccelerometerData.append(line)
        case .headphoneGyroscope:
            self.headphoneGyroscopeData.append(line)
        default:
            print("No data of \(sensorType) is available.")
        }
    }
    
    
    mutating func getURLs(label: String, subject: String) -> SensorDataRecord {
        let format = DateFormatter()
        format.dateFormat = "yyyyMMddHHmmss"
        let time = format.string(from: Date())
        
        print("\(label), \(subject)")
        
        /* 一時ファイルを保存する場所 */
        let tmppath = NSHomeDirectory() + "/tmp"
        
        let apd = "\(time)_\(label)_\(subject)" // 付加する文字列(時間+ラベル+ユーザ名)
        // ファイル名を生成
        let accelerometerFilepath = tmppath + "/phone_accelerometer_\(apd).csv"
        let gyroFilepath = tmppath + "/phone_gyroscope_\(apd).csv"
        let magnetFilepath = tmppath + "/phone_magnetometer_\(apd).csv"
        
        let headphoneAccelerometerFilepath = tmppath + "/headphone_accelerometer_\(apd).csv"
        let headphoneGyroscopeFilepath = tmppath + "/headphone_gyroscope_\(apd).csv"
        
        // ファイルを書き出す
        do {
            // データを計測していなければ保存しない
            if self.accelerometerData != self.column {
                try self.accelerometerData.write(toFile: accelerometerFilepath, atomically: true, encoding: String.Encoding.utf8)
                try self.gyroscopeData.write(toFile: gyroFilepath, atomically: true, encoding: String.Encoding.utf8)
                try self.magnetometerData.write(toFile: magnetFilepath, atomically: true, encoding: String.Encoding.utf8)
            }
            
            // データを計測していなければ保存しない
            if self.headphoneAccelerometerData != self.column {
                try self.headphoneAccelerometerData.write(toFile: headphoneAccelerometerFilepath, atomically: true, encoding: String.Encoding.utf8)
                try self.headphoneGyroscopeData.write(toFile: headphoneGyroscopeFilepath, atomically: true, encoding: String.Encoding.utf8)
            }
        }
        catch let error as NSError{
            print("Failure to Write File\n\(error)")
        }
        
        /* 書き出したcsvファイルの場所を取得 */
        var urls = [URL]()
        
        // 計測したデバイスの種類
        var deviceTypes = [DeviceType]()
        
        if self.accelerometerData != self.column {
            deviceTypes.append(.phone)
            
            urls.append(URL(fileURLWithPath: accelerometerFilepath))
            urls.append(URL(fileURLWithPath: gyroFilepath))
            urls.append(URL(fileURLWithPath: magnetFilepath))
        }
        
        if self.headphoneAccelerometerData != self.column {
            deviceTypes.append(.headphone)
            
            urls.append(URL(fileURLWithPath: headphoneAccelerometerFilepath))
            urls.append(URL(fileURLWithPath: headphoneGyroscopeFilepath))
        }
        
        // データをリセットする
        self.reset()
         
        let record = SensorDataRecord(timestamp: time, urls: urls, deviceTypes: deviceTypes)
        return record
    }
    
    // 保存したファイルパスを取得する
    mutating func getURLs(label: String, subject: String) -> [URL] {
        let record: SensorDataRecord = self.getURLs(label: label, subject: subject)
        
        return record.urls
    }
    
    // データをリセットする
    mutating func reset() {
            self.accelerometerData = self.column
            self.gyroscopeData = self.column
            self.magnetometerData = self.column
            
            self.headphoneAccelerometerData = self.column
            self.headphoneGyroscopeData = self.column
        }
}


struct WatchSensorData {
    var accelerometerData: String
    var gyroscopeData: String
    
    private let column = "time,x,y,z\n"
    
    public init() {
        self.accelerometerData = self.column
        self.gyroscopeData = self.column
    }
    
    mutating func append(line: String, sensorType: SensorType) {
        switch sensorType {
        case .watchAccelerometer:
            self.accelerometerData.append(line)
        case .watchGyroscope:
            self.gyroscopeData.append(line)
        default:
            print("No data of \(sensorType) is available.")
        }
    }
    
    mutating func getDataURLs(label: String, subject: String) -> SensorDataRecord? {
        if self.accelerometerData == self.column {
            return nil
        }
        
        let format = DateFormatter()
        format.dateFormat = "yyyyMMddHHmmss"
        let time = format.string(from: Date())
        
        print("\(label), \(subject)")
        
        /* 一時ファイルを保存する場所 */
        let tmppath = NSHomeDirectory() + "/tmp"
        
        let apd = "\(time)_\(label)_\(subject)" // 付加する文字列(時間+ラベル+ユーザ名)
        // ファイル名を生成
        let accelerometerFilepath = tmppath + "/watch_accelerometer_\(apd).csv"
        let gyroFilepath = tmppath + "/watch_gyroscope_\(apd).csv"
        
        // ファイルを書き出す
        do {
            try self.accelerometerData.write(toFile: accelerometerFilepath, atomically: true, encoding: String.Encoding.utf8)
            try self.gyroscopeData.write(toFile: gyroFilepath, atomically: true, encoding: String.Encoding.utf8)
        }
        catch let error as NSError{
            print("Failure to Write File\n\(error)")
        }
        
        /* 書き出したcsvファイルの場所を取得 */
        var urls = [URL]()
        urls.append(URL(fileURLWithPath: accelerometerFilepath))
        urls.append(URL(fileURLWithPath: gyroFilepath))

        // データをリセットする
        self.resetData()
        
        let record = SensorDataRecord(timestamp: time, urls: urls, deviceTypes: [.watch])
        return record
    }
    
    // 保存したファイルパスを取得する
    mutating func getDataURLs(label: String, subject: String) -> [URL] {
        let record: SensorDataRecord? = getDataURLs(label: label, subject: subject)
        
        return record?.urls ?? [URL]()
    }
    
    // データをリセットする
    mutating func resetData() {
        self.accelerometerData = self.column
        self.gyroscopeData = self.column
    }
}

