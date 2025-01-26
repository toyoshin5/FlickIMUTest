//
//  MLService.swift
//  FlickIMUTest
//
//  Created by Shingo Toyoda on 2025/01/27.
//
import CoreML

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
    
    func predict(_ input: [[Double]]) -> MLResult? {
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
                //最大となるインデックスと値を取得
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
