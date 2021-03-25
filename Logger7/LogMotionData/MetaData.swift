//
//  PhoneSensorData.swift
//  LoggerWatchPods
//
//  Created by Satoshi on 2020/10/30.
//
import Foundation
import Combine


// Metadata
final class MetaData: ObservableObject {
    @Published var name = ""
    @Published var label = ""
}

enum TrampolineActivity: String, CaseIterable {
    case stand = "stand"
    case walk = "walk"
    case march = "march"
    case two_jump = "two-jump"
    case one_jump_left = "one-jump-left"
    case one_jump_right = "one-jump-right"
}
