//
//  TimestampUtils.swift
//  LoggerWatchPods
//
//  Created by Satoshi on 2020/10/30.
//
import Foundation


func getTimestamp() -> String {
    let format = DateFormatter()
    format.dateFormat = "yyyy/MM/dd HH:mm:ss.SSS"
    return format.string(from: Date())
}
