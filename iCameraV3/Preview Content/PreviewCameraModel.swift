//
//  PreviewCameraModel.swift
//  iCameraV3
//
//  Created by Ima Da Costa on 25/07/2024.
//

import AVFoundation
import SwiftUI

class PreviewCameraModel: CameraModel {
    override init() {
        super.init()
        self.previewLayer.session = AVCaptureSession()
        self.thumbnail = UIImage(systemName: "photo") // Example thumbnail for preview
    }

    init(captureMode: CaptureMode) {
        super.init()
        self.captureMode = captureMode
    }

    override func capturePhoto() async {
        // Preview mock implementation
    }

    override func toggleRecording() async {
        // Preview mock implementation
    }

    override func switchVideoDevices() async {
        // Preview mock implementation, no async needed
    }
}
