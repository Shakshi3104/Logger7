//
//  HistoryView.swift
//  Logger7
//
//  Created by Satoshi on 2021/03/04.
//  Copyright © 2021 MacBook Pro. All rights reserved.
//

import SwiftUI

struct HistoryView: View {
    @ObservedObject var sensorDataManager = SensorDataManager.shared
    
    var body: some View {
        VStack {
            if sensorDataManager.storedData.count == 0 {
                Text("No Data")
            }
            else {
                List {
                    ForEach(0..<sensorDataManager.storedData.count, id: \.self) { index in
                        HistoryListRow(record: sensorDataManager.storedData[index])
                            .padding()
                            
                    }
                }.listStyle(InsetGroupedListStyle())
                
            }
        }
    }
}

struct HistoryListRow: View {
    var record: SensorDataRecord
    @State var isPresent = false
    
    var body: some View {
        HStack {
            Text(record.timestamp)
            Spacer()
            ForEach(0..<record.deviceTypes.count) { index in
                Image(systemName: record.deviceTypes[index].rawValue)
            }
        }
        .onLongPressGesture {
            let switchFeedback = UIImpactFeedbackGenerator(style: .heavy)
            
            switchFeedback.impactOccurred()
                self.isPresent = true
        }
        .sheet(isPresented: $isPresent, content: {
            ActivityView(activityItems: record.urls, applicationActivities: nil)
        })
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
    }
}
