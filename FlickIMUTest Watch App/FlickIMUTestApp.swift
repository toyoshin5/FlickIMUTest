//
//  FlickIMUTestApp.swift
//  FlickIMUTest Watch App
//
//  Created by Shingo Toyoda on 2025/01/27.
//

import SwiftUI

@main
struct FlickIMUTest_Watch_AppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

enum AppGesture: Int {
    case tap = 0
    case up = 1
    case down = 2
    case left = 3
    case right = 4
}
