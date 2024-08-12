//
//  PreviewSource.swift
//  iCameraV3
//
//  Created by Ima Da Costa on 12/08/2024.
//

import Foundation
import AVFoundation

protocol PreviewSource {
    var previewLayer: AVCaptureVideoPreviewLayer { get }
    func startPreview()
    func stopPreview()
}

