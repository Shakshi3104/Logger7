//
//  ContentView.swift
//  LoggerWatchPods
//
//  Created by Satoshi on 2020/10/30.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            LogView().tabItem {
                Image(systemName: "gyroscope")
                Text("Log Motion")
            }
            
            HistoryView().tabItem {
                Image(systemName: "clock")
                Text("History")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
