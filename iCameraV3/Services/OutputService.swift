//
//  OutputService.swift
//  iCameraV3
//
//  Created by Ima Da Costa on 11/08/2024.
//

import Foundation
import AVFoundation

/// A protocol defining the requirements for an output service.
protocol OutputService {
    associatedtype Output: AVCaptureOutput
    var output: Output { get }
    var captureActivity: CaptureActivity { get }
    var capabilities: CaptureCapabilities { get }
    func updateConfiguration(for device: AVCaptureDevice)
    func setVideoRotationAngle(_ angle: CGFloat)
}

extension OutputService {
    func setVideoRotationAngle(_ angle: CGFloat) {
        // Set the rotation angle on the output object's video connection.
        if let connection = output.connection(with: .video) {
            // If video orientation needs to be updated, do so here
            connection.videoRotationAngle = angle
        }
    }
    
    func updateConfiguration(for device: AVCaptureDevice) {
        // This function can be overridden by the conforming type to handle specific configurations.
    }
}
