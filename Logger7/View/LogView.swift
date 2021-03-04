//
//  LogView.swift
//  Logger7
//
//  Created by Satoshi on 2021/03/04.
//  Copyright © 2021 MacBook Pro. All rights reserved.
//

import SwiftUI

struct LogView: View {
    @State private var isLogStarted = false
    @State private var isSharePresented = false
    
    @ObservedObject var sensorLogger = PhoneSensorManager()
    @ObservedObject var connector = WatchConnector()
    
    @State private var backgroundTaskID: UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier(rawValue: 3104)
    
    @ObservedObject var metadata = MetaData()
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                
                // 保存ボタン
                Button(action: {
                    self.isSharePresented.toggle()
                }, label: {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Save")
                    }
                })
                .sheet(isPresented: self.$isSharePresented, content: {
                    EditView(isPresent: self.$isSharePresented,
                             metadata: metadata,
                             sensorLogger: sensorLogger,
                             connector: connector)
                })
                
                Spacer()
                
                // 計測ボタン
                Button(action: {
                    
                }) {
                    if isLogStarted {
                        // ダブルタップ or 長押しで計測をストップ
                        HStack {
                            Image(systemName: "pause.circle")
                            Text("Stop")
                        }
                        .onTapGesture(count: 2, perform: {
                            self.action(true)
                        })
                        .onLongPressGesture {
                            self.action(true)
                        }
                    }
                    else {
                        HStack {
                            Image(systemName: "play.circle")
                            Text("Start")
                        }.onTapGesture {
                            self.action(false)
                        }
                        
                    }
                }
                
                Spacer()
            }
            .padding(.vertical)
            
            // センサ値の表示
            VStack {
                HStack {
                    Image(systemName: "iphone")
                    Text("iPhone").font(.headline)
                }
                
                HStack {
                    Image(systemName: "speedometer")
                    Spacer()
                    Text(String(format: "%.3f", sensorLogger.accX))
                        .multilineTextAlignment(.leading)
                    Spacer()
                    Text(String(format: "%.3f", sensorLogger.accY))
                        .multilineTextAlignment(.leading)
                    Spacer()
                    Text(String(format: "%.3f", sensorLogger.accZ))
                        .multilineTextAlignment(.leading)
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 2)
                
                HStack {
                    Image(systemName: "gyroscope")
                    Spacer()
                    Text(String(format: "%.3f", sensorLogger.gyrX))
                        .multilineTextAlignment(.leading)
                    Spacer()
                    Text(String(format: "%.3f", sensorLogger.gyrY))
                        .multilineTextAlignment(.leading)
                    Spacer()
                    Text(String(format: "%.3f", sensorLogger.gyrZ))
                        .multilineTextAlignment(.leading)
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 2)
                
                HStack {
                    Image(systemName: "safari")
                    Spacer()
                    Text(String(format: "%.3f", sensorLogger.magX))
                        .multilineTextAlignment(.leading)
                    Spacer()
                    Text(String(format: "%.3f", sensorLogger.magY))
                        .multilineTextAlignment(.leading)
                    Spacer()
                    Text(String(format: "%.3f", sensorLogger.magZ))
                        .multilineTextAlignment(.leading)
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 2)
            }
            .padding(.vertical, 10)
            
            VStack {
                HStack {
                    Image(systemName: "applewatch")
                    Text("Watch").font(.headline)
                }
                
                HStack {
                    Image(systemName: "speedometer")
                    Spacer()
                    Text(String(format: "%.3f", connector.accX))
                        .multilineTextAlignment(.leading)
                    Spacer()
                    Text(String(format: "%.3f", connector.accY))
                        .multilineTextAlignment(.leading)
                    Spacer()
                    Text(String(format: "%.3f", connector.accZ))
                        .multilineTextAlignment(.leading)
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 2)
                
                HStack {
                    Image(systemName: "gyroscope")
                    Spacer()
                    Text(String(format: "%.3f", connector.gyrX))
                        .multilineTextAlignment(.leading)
                    Spacer()
                    Text(String(format: "%.3f", connector.gyrY))
                        .multilineTextAlignment(.leading)
                    Spacer()
                    Text(String(format: "%.3f", connector.gyrZ))
                        .multilineTextAlignment(.leading)
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 2)
                
            }
            .padding(.vertical, 10)
            
            VStack {
                HStack {
                    Image(systemName: "airpodspro")
                    Text("AirPods Pro").font(.headline)
                }
                
                HStack {
                    Image(systemName: "speedometer")
                    Spacer()
                    Text(String(format: "%.3f", sensorLogger.headAccX))
                        .multilineTextAlignment(.leading)
                    Spacer()
                    Text(String(format: "%.3f", sensorLogger.headAccY))
                        .multilineTextAlignment(.leading)
                    Spacer()
                    Text(String(format: "%.3f", sensorLogger.headAccZ))
                        .multilineTextAlignment(.leading)
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 2)
                
                HStack {
                    Image(systemName: "gyroscope")
                    Spacer()
                    Text(String(format: "%.3f", sensorLogger.headGyrX))
                        .multilineTextAlignment(.leading)
                    Spacer()
                    Text(String(format: "%.3f", sensorLogger.headGyrY))
                        .multilineTextAlignment(.leading)
                    Spacer()
                    Text(String(format: "%.3f", sensorLogger.headGyrZ))
                        .multilineTextAlignment(.leading)
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 2)
                
            }
            .padding(.vertical, 10)
            
        }
    }
    
    func action(_ LargeFeedback: Bool) {
        self.isLogStarted.toggle()
        
        let switchFeedback: UIImpactFeedbackGenerator
        if LargeFeedback {
            switchFeedback = UIImpactFeedbackGenerator(style: .heavy)
        }
        else {
            switchFeedback = UIImpactFeedbackGenerator(style: .medium)
        }
        switchFeedback.impactOccurred()
        
        if self.isLogStarted {
            // バックグラウンドタスク
            self.backgroundTaskID =
            UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
            
            // 計測スタート
            var samplingFrequency = UserDefaults.standard.integer(forKey: "frequency_preference")
                                    
            print("sampling frequency = \(samplingFrequency)")
            
            // なぜかサンプリング周波数が0のときは100にしておく
            if samplingFrequency == 0 {
                samplingFrequency = 100
            }
            
            self.sensorLogger.startUpdate(Double(samplingFrequency))
        }
        else {
            self.sensorLogger.stopUpdate()
            UIApplication.shared.endBackgroundTask(self.backgroundTaskID)
        }
    }
}

// View for inputting information
struct EditView: View {
    @Binding var isPresent: Bool
    @ObservedObject var metadata: MetaData
    @ObservedObject var sensorLogger: PhoneSensorManager
    @ObservedObject var connector: WatchConnector
    @ObservedObject var sensorDataManager = SensorDataManager.shared
    
    @State var isSharedPresent = false
    @State var isEmptyMetadata = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("What's your name?")) {
                    TextField("Subject Name", text: $metadata.name)
                }
                
                Section(header: Text("What's label?")) {
                    TextField("Label", text: $metadata.label)
                }
            }
            .navigationBarTitle("Send Data", displayMode: .inline)
            .navigationBarItems(leading:
                                    Button(action: {
                                        if metadata.name.isEmpty || metadata.label.isEmpty {
                                            self.isSharedPresent = false
                                            self.isEmptyMetadata = true
                                            
                                            // Haptic Engineへのフィードバック
                                            let errorFeedback = UINotificationFeedbackGenerator()
                                            errorFeedback.notificationOccurred(.error)
                                        }
                                        else {
                                            let switchFeedback = UIImpactFeedbackGenerator(style: .heavy)
                                            
                                            switchFeedback.impactOccurred()
                                            
                                            self.isSharedPresent = true
                                            self.isEmptyMetadata = false
                                        }
                                    }, label: {
                                        Image(systemName: "square.and.arrow.up")
                                    })
                                    .sheet(isPresented: $isSharedPresent, content: {
                                        ActivityView(activityItems: sensorDataManager.getURLs(label: metadata.label, subject: metadata.name), applicationActivities: nil)
                                    })
                                    .alert(isPresented: $isEmptyMetadata, content: {
                                        Alert(title: Text("保存できません"), message: Text("Subject NameとLabelを入力してください"))
                                    }),
                                trailing:
                                    Button(action: {
                                        self.isPresent = false
                                    }
                                    , label: {
                                        Text("Done")
                                    })
                                    
            )
        }
    }
}


// ActivityViewController
struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]?
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityView>) -> UIActivityViewController {
        return UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityView>) {
        // Nothing to do
    }
}

struct LogView_Previews: PreviewProvider {
    static var previews: some View {
        LogView()
    }
}
