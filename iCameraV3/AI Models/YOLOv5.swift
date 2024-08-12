//
//  YoloV9.swift
//  iCameraV3
//
//  Created by Ima Da Costa on 11/08/2024.
//

/*
import Foundation
import CoreML
import Vision

func predict(image: UIImage) {
    guard let model = try? YOLOv10s(configuration: .init()) else {
        fatalError("Failed to load model")
    }

    guard let cgImage = image.cgImage else {
        fatalError("Failed to convert UIImage to CGImage")
    }

    let request = VNCoreMLRequest(model: VNCoreMLModel(for: model)) { (request, error) in
        guard let results = request.results as? [VNRecognizedObjectObservation] else {
            fatalError("Unexpected result type from VNCoreMLRequest")
        }

        for observation in results {
            print("Label: \(observation.labels[0].identifier), confidence: \(observation.labels[0].confidence)")
        }
    }

    let handler = VNImageRequestHandler(cgImage: cgImage)
    try? handler.perform([request])
}

class YOLOv9 {
    var model: MLModel {
        return try! MLModel(contentsOf: URL(fileURLWithPath: "path/to/your/model"))
    }
}
*/
