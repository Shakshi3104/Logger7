//
//  WatchConnector.swift
//  Logger6
//
//  Created by MacBook Pro on 2020/08/02.
//  Copyright © 2020 MacBook Pro. All rights reserved.
//
import Foundation
import UIKit
import WatchConnectivity

class WatchConnector: NSObject, ObservableObject, WCSessionDelegate {
    
    var saver = WatchSensorData()
    
    // Sensor values from Apple Watch
    @Published var accX = 0.0
    @Published var accY = 0.0
    @Published var accZ = 0.0
    @Published var gyrX = 0.0
    @Published var gyrY = 0.0
    @Published var gyrZ = 0.0
    
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
        print("Phone: didReceive: \(message)")
        
        DispatchQueue.main.async {
            if let accData = message["ACC_DATA"] as? String {
                self.saver.append(line: accData, sensorType: .watchAccelerometer)
                
                if accData.count != 0 {
                    // iPhone上で表示する
                    let accDataDouble = self.stringToDouble(data: accData)
                    self.accX = accDataDouble[0]
                    self.accY = accDataDouble[1]
                    self.accZ = accDataDouble[2]
                }
            }
            
            if let gyrData = message["GYR_DATA"] as? String {
                self.saver.append(line: gyrData, sensorType: .watchGyroscope)
                
                if gyrData.count != 0 {
                    let gyrDataDouble = self.stringToDouble(data: gyrData)
                    self.gyrX = gyrDataDouble[0]
                    self.gyrY = gyrDataDouble[1]
                    self.gyrZ = gyrDataDouble[2]
                }
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
    
    // 保存したファイルパスを取得する
    mutating func getDataURLs(label: String, subject: String) -> [URL] {
        let format = DateFormatter()
        format.dateFormat = "yyyyMMddHHmmss"
        let time = format.string(from: Date())
        
        /* 一時ファイルを保存する場所 */
        let tmppath = NSHomeDirectory() + "/tmp"
        
        let apd = "\(time)_\(label)_\(subject)" // 付加する文字列(時間+ラベル+ユーザ名)
        // ファイル名を生成
        let accelerometerFilepath = tmppath + "/watch_accelermeter_\(apd).csv"
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
        
        return urls
    }
    
    // データをリセットする
    mutating func resetData() {
        self.accelerometerData = self.column
        self.gyroscopeData = self.column
    }
}
