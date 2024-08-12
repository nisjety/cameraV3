//
//  DefaultPreviewSource.swift
//  iCameraV3
//
//  Created by Ima Da Costa on 12/08/2024.
//

import Foundation
import AVFoundation


class DefaultPreviewSource: PreviewSource {
    private let session: AVCaptureSession
    private let videoPreviewLayer: AVCaptureVideoPreviewLayer

    init(session: AVCaptureSession) {
        self.session = session
        self.videoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
        self.videoPreviewLayer.videoGravity = .resizeAspectFill
    }

    var previewLayer: AVCaptureVideoPreviewLayer {
        return videoPreviewLayer
    }

    func startPreview() {
        if !session.isRunning {
            session.startRunning()
        }
    }

    func stopPreview() {
        if session.isRunning {
            session.stopRunning()
        }
    }
}
