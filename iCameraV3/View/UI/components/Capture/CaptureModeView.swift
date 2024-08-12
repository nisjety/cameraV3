//
//  CaptureModeView.swift
//  iCameraV3
//
//  Created by Ima Da Costa on 25/07/2024.
//
import SwiftUI

struct CaptureModeView<CameraModel: Camera & ObservableObject>: View {
    @ObservedObject var camera: CameraModel
    @Binding var direction: SwipeDirection

    var body: some View {
        Picker("Capture Mode", selection: $camera.captureMode) {
            ForEach(CaptureMode.allCases, id: \.self) {
                Image(systemName: $0.systemName)
                    .tag($0)
            }
        }
        .frame(width: 180)
        .pickerStyle(.segmented)
        .disabled(camera.captureActivity.isRecording)
        .onChange(of: direction) { _, _ in
            let modes = CaptureMode.allCases
            let selectedIndex = modes.firstIndex(of: camera.captureMode) ?? -1
            let increment = direction == .right
            let newIndex = selectedIndex + (increment ? 1 : -1)

            guard newIndex >= 0, newIndex < modes.count else { return }
            camera.captureMode = modes[newIndex]
        }
    }
}
