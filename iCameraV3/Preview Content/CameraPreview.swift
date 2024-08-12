//
//  CameraPreview.swift
//  iCameraV3
//
//  Created by Ima Da Costa on 03/08/2024.
//

import SwiftUI
import AVFoundation

struct CameraPreview: UIViewRepresentable {
    class Coordinator: NSObject {
        var parent: CameraPreview

        init(parent: CameraPreview) {
            self.parent = parent
        }
    }

    var previewLayer: AVCaptureVideoPreviewLayer

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        previewLayer.frame = view.frame
        view.layer.addSublayer(previewLayer)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // Update the view with any necessary changes
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
}
