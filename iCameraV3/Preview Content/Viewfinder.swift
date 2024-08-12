//
//  Viewfinder.swift
//  iCameraV3
//
//  Created by Ima Da Costa on 25/07/2024.
//

import SwiftUI
import AVFoundation

struct Viewfinder: View {
    var previewLayer: AVCaptureVideoPreviewLayer
    var onTap: (CGPoint) -> Void

    var body: some View {
        CameraPreview(previewLayer: previewLayer)
            .edgesIgnoringSafeArea(.all)
            .onTapGesture { location in
                onTap(location)
            }
    }
}
