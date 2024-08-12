//
//  SwitchCameraButton.swift
//  iCameraV3
//
//  Created by Ima Da Costa on 06/08/2024.
//

import SwiftUI
import AVFoundation

/// A view that displays a button to switch between available cameras.
struct SwitchCameraButton<CameraModel: Camera & ObservableObject>: View {
    @ObservedObject var camera: CameraModel
    @State private var isPressed: Bool = false
    
    var body: some View {
        Button {
            Task {
                await camera.switchVideoDevices()
            }
        } label: {
            Image(systemName: iconName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: xmediumButtonSize.width, height: xmediumButtonSize.height)
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.blue.opacity(1),
                            Color.blue.opacity(0.5),
                            Color.blue.opacity(1),
                            Color.blue.opacity(0.4)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .scaleEffect(isPressed ? 0.9 : 1.0) // Apply scale effect
                .animation(.easeInOut(duration: 0.3), value: isPressed)
        }
        .buttonStyle(DefaultButtonStyle(size: .large))
        .frame(width: xmediumButtonSize.width, height: xmediumButtonSize.height)
        .disabled(camera.captureActivity.isRecording)
        .allowsHitTesting(!camera.isSwitchingVideoDevices)
        .onLongPressGesture(
            minimumDuration: .infinity,
            pressing: { isPressing in
                withAnimation {
                    isPressed = isPressing
                }
            },
            perform: {}
        )
    }
    
    private var iconName: String {
        return isPressed ? "camera.rotate.fill" : "camera.rotate"
    }
}

#Preview {
    SwitchCameraButton(camera: PreviewCameraModel())
        .padding()
        .previewDevice("iPhone 15 Pro")
        .previewDisplayName("iPhone 15 Pro")
}
