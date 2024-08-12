//
//  PreviewContainer.swift
//  iCameraV3
//
//  Created by Ima Da Costa on 25/07/2024.
//

import SwiftUI

// Portrait-orientation aspect ratios.
typealias AspectSize = CGSize
let photoAspectSize = AspectSize(width: 3.0, height: 4.0)
let movieAspectSize = AspectSize(width: 9.0, height: 16.0)

/// A view that provides a container view around the camera preview.
///
/// This view applies transition effects when changing capture modes or switching devices.
/// On a compact device size, the app also uses this view to offset the vertical position
/// of the camera preview to better fit the UI when in photo capture mode.
@MainActor
struct PreviewContainer<Content: View, CameraModel: ObservableObject & Camera>: View {
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @StateObject var camera: CameraModel
    
    // State values for transition effects.
    @State private var blurRadius = CGFloat.zero
    
    // When running in photo capture mode on a compact device size, move the preview area
    // update by the offset amount so that it's better centered between the top and bottom bars.
    private let photoModeOffset = CGFloat(-44)
    private let content: Content
    
    init(camera: CameraModel, @ViewBuilder content: () -> Content) {
        self._camera = StateObject(wrappedValue: camera)
        self.content = content()
    }
    
    var body: some View {
        // On compact devices, show a view finder rectangle around the video preview bounds.
        if horizontalSizeClass == .compact {
            ZStack {
                previewView
            }
            .clipped()
            // Apply an appropriate aspect ratio based on the selected capture mode.
            .aspectRatio(aspectRatio, contentMode: .fit)
            // In photo mode, adjust the vertical offset of the preview area to better fit the UI.
            .offset(y: camera.captureMode == .photo ? photoModeOffset : 0)
        } else {
            // On regular-sized UIs, show the content in full screen.
            previewView
        }
    }
    
    /// Attach animations to the camera preview.
    var previewView: some View {
        content
            .blur(radius: blurRadius, opaque: true)
            .onChange(of: camera.isSwitchingVideoDevices) { oldValue, newValue in
                print("Switching video devices from \(oldValue) to \(newValue)")
                updateBlurRadius(newValue)
            }
    }
    
    func updateBlurRadius(_ isSwitching: Bool) {
        withAnimation {
            blurRadius = isSwitching ? 30 : 0
        }
    }
    
    var aspectRatio: AspectSize {
        camera.captureMode == .photo ? photoAspectSize : movieAspectSize
    }
}
