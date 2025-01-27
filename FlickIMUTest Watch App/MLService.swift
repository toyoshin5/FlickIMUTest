//
//  MLService.swift
//  FlickIMUTest
//
//  Created by Shingo Toyoda on 2025/01/27.
//
import CoreML
import CoreMotion

class MLService {
    
    let shape = [1, 39, 16] as [NSNumber] // 入力の形状を指定
    private var flickModel: FlickModel?
    
    init() {
        do {
            flickModel = try FlickModel(configuration: MLModelConfiguration())
        } catch {
            print("モデルのロードに失敗しました: \(error)")
        }
    }
    
    func predict(_ cmInput: [CMDeviceMotion]) -> MLResult? {
        let input = deviceMotionToDoubleArray(cmInput)
        guard let inputArray = try? MLMultiArray(shape: shape, dataType: .double) else {
            fatalError("MLMultiArrayの作成に失敗しました")
        }
        for i in 0..<39 {
            for j in 0..<16 {
                let index = [0, i, j] as [NSNumber]
                let value = input[i][j]
                inputArray[index] = NSNumber(value: value)
            }
        }
        if let model = flickModel {
            let input = FlickModelInput(conv1d_input: inputArray)
            do {
                let prediction:FlickModelOutput = try model.prediction(input: input)
                let output = mlMultiArrayToDoubleArray(prediction.Identity)
                let maxValue = output.max() ?? 0
                if let maxIndex = output.firstIndex(of: maxValue){
                    return MLResult(label: AppGesture(rawValue: maxIndex) ?? .tap, probability: maxValue)
                }
                return nil
            } catch {
                print("推論に失敗しました: \(error)")
                return nil
            }
        }
        return nil
    }
    
    private func deviceMotionToDoubleArray(_ motion: [CMDeviceMotion]) -> [[Double]] {
        var input = [[Double]]()
        for motionData in motion {
            var data = [Double]()
            data.append(motionData.userAcceleration.x)
            data.append(motionData.userAcceleration.y)
            data.append(motionData.userAcceleration.z)
            data.append(motionData.attitude.pitch)
            data.append(motionData.attitude.roll)
            data.append(motionData.attitude.yaw)
            data.append(motionData.gravity.x)
            data.append(motionData.gravity.y)
            data.append(motionData.gravity.z)
            data.append(motionData.attitude.quaternion.x)
            data.append(motionData.attitude.quaternion.y)
            data.append(motionData.attitude.quaternion.z)
            data.append(motionData.attitude.quaternion.w)
            data.append(motionData.rotationRate.x)
            data.append(motionData.rotationRate.y)
            data.append(motionData.rotationRate.z)
            input.append(data)
            print("\(motionData.userAcceleration.x),\(motionData.userAcceleration.y),\(motionData.userAcceleration.z)")
        }
        return input
    }

    private func mlMultiArrayToDoubleArray(_ multiArray: MLMultiArray) -> [Double] {
        let length = multiArray.count
        let doublePtr =  multiArray.dataPointer.bindMemory(to: Float16.self, capacity: length)
        let doubleBuffer = UnsafeBufferPointer(start: doublePtr, count: length)
        let output = Array(doubleBuffer).compactMap { Double($0) }
        return output
    }
        
        
}

struct MLResult {
    let label: AppGesture
    let probability: Double
}
