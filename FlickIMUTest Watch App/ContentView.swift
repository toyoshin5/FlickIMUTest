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
    @State var result: MLResult?
    @GestureState var isPressing = false
    
    var body: some View {
        Button(action: pred){
            ZStack{
                if let result {
                    AppArrow(gesture: result.label)
                }
                VStack {
                    Spacer()
                    if let result = result {
                        Text("\(result.probability)")
                            .foregroundColor(.white)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
        }
        .buttonStyle(PlainButtonStyle())
        .background(Color.black)
        .onAppear() {
            startMotionUpdates()
        }

    }

    func pred(){
        Task {
            try? await Task.sleep(nanoseconds: UInt64(10_000_000 * PRED_DELAY)) // 20ms
            if self.motionData.count >= 39 {
                if let output = self.ml.predict(Array(self.motionData.suffix(39))){
                    self.result = output
                    print(output)
                    WKInterfaceDevice.current().play(.click)
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

struct AppArrow: View {
    let gesture: AppGesture
    var body: some View {
        Group{
            switch gesture {
            case .tap:
                Image(systemName: "dot.circle")
            case .up:
                Image(systemName: "arrow.up")
            case .down:
                Image(systemName: "arrow.down")
            case .left:
                Image(systemName: "arrow.left")
            case .right:
                Image(systemName: "arrow.right")
            }
        }
        .font(.system(size: 80, weight: .bold))
    }
}

#Preview {
    ContentView()
}
