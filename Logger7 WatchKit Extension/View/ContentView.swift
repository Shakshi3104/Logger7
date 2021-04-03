//
//  ContentView.swift
//  LoggerWatchPods WatchKit Extension
//
//  Created by Satoshi on 2020/10/30.
//

import SwiftUI

struct ContentView: View {
    @State private var logStarting = false
    @ObservedObject var sensorLogger = WatchSensorManager()
    
    var body: some View {
        VStack {
            Button(action: {
                self.logStarting.toggle()
                
                if self.logStarting {
                    // 計測スタート
                    var samplingFrequency = UserDefaults.standard.integer(forKey: "frequency_preference")
                    
                    print("sampling frequency = \(samplingFrequency) on watch")
                    
                    // なぜかサンプリング周波数が0のときは100にしておく
                    if samplingFrequency == 0 {
                        samplingFrequency = 100
                    }
                    
                    self.sensorLogger.startUpdate(Double(samplingFrequency))
                }
                else {
                    self.sensorLogger.stopUpdate()
                    
                }
            }) {
                if self.logStarting {
                    Image(systemName: "pause.circle")
                }
                else {
                    Image(systemName: "play.circle")
                }
            }
            
            VStack {
                VStack {
                Text("Accelerometer").font(.headline)
                HStack {
                    Text(String(format: "%.2f", self.sensorLogger.accX))
                    Spacer()
                    Text(String(format: "%.2f", self.sensorLogger.accY))
                    Spacer()
                    Text(String(format: "%.2f", self.sensorLogger.accZ))
                }.padding(.horizontal)
                }
                
                VStack {
                Text("Gyroscope").font(.headline)
                HStack {
                    Text(String(format: "%.2f", self.sensorLogger.gyrX))
                    Spacer()
                    Text(String(format: "%.2f", self.sensorLogger.gyrY))
                    Spacer()
                    Text(String(format: "%.2f", self.sensorLogger.gyrZ))
                }.padding(.horizontal)
                }

            }
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
