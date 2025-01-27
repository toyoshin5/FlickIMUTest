//
//  ContentView.swift
//  FlickIMUTest Watch App
//
//  Created by Shingo Toyoda on 2025/01/27.
//

import SwiftUI
import CoreML
import CoreMotion
import HealthKit

struct ContentView: View {
    let ml = MLService()
    let motionManager = CMMotionManager()
    let MAX_MOTION_LIST:Int = 40
    let PRED_DELAY:Int = 20
    @State var motionData: [CMDeviceMotion] = []
    @State var isCollecting = false
    @State var log = ""
    
    var body: some View {
        VStack {
            Button(action: {
                pred()
            }) {
                Text("Predict")
            }
            Text(log)
        }
        .onAppear() {
            startMotionUpdates()
        }
        .padding()
    }

    func pred(){
        Task {
            try? await Task.sleep(nanoseconds: UInt64(10_000_000 * PRED_DELAY)) // 20ms
            if self.motionData.count >= 39 {
                if let output = self.ml.predict(Array(self.motionData.suffix(39))){
                    self.log = "\(output)"
                    print(output)
                }
            } else {
                print("Not enough data collected yet")
            }
        }
       
    }
    
    func startMotionUpdates() {
        guard motionManager.isDeviceMotionAvailable else {
            print("Device motion not available")
            return
        }
        
        motionManager.startDeviceMotionUpdates(to: .main) { (motion, error) in
            guard let motion = motion else { return }
            
            // 最新のモーションデータを追加
            self.motionData.append(motion)
            
            // 最大39フレームを保持
            if self.motionData.count >= MAX_MOTION_LIST {
                self.motionData.removeFirst()
            }
        }
    }
}

#Preview {
    ContentView()
}
