
//  CaptureButton.swift

import SwiftUI
import AVFoundation
import Combine

/// A view that displays an appropriate capture button for the selected mode.
@MainActor
struct CaptureButton<CameraModel: Camera & ObservableObject>: View {
    @ObservedObject var camera: CameraModel
    @Binding var selectedMode: Mode
    
    private let mainButtonDimension: CGFloat = 68
    
    var body: some View {
        captureButton
            .aspectRatio(1.0, contentMode: .fit)
            .frame(width: mainButtonDimension)
    }
    
    @ViewBuilder
    var captureButton: some View {
        switch selectedMode.name {
        case "Photo", "Portrait", "Macro Mode", "Panorama": // Add other photo modes here
            PhotoCaptureButton {
                Task {
                    let options = camera.photoSaveOptions // Assuming you have a property `photoSaveOptions` in `CameraModel`
                    await camera.capturePhoto(options: options)
                }
            }
        default: // Assume other modes are video/movie modes
            MovieCaptureButton { _ in
                Task {
                    await camera.toggleRecording()
                }
            }
        }
    }
}

#Preview("Photo") {
    CaptureButton(camera: PreviewCameraModel(captureMode: .photo), selectedMode: .constant(Mode(name: "Photo")))
}

#Preview("Video") {
    CaptureButton(camera: PreviewCameraModel(captureMode: .video), selectedMode: .constant(Mode(name: "Video")))
}

private struct PhotoCaptureButton: View {
    private let action: () -> Void
    private let lineWidth = CGFloat(4.0)

    init(action: @escaping () -> Void) {
        self.action = action
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: lineWidth)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.gray.opacity(0.7), Color.white.opacity(0.8)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            Button {
                let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .medium)
                impactFeedbackgenerator.impactOccurred()
                action()
            } label: {
                Circle()
                    .inset(by: lineWidth * 1.17)
                    .fill(.white.opacity(0.95))
            }
            .buttonStyle(PhotoButtonStyle())
        }
    }

    struct PhotoButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .scaleEffect(configuration.isPressed ? 0.65 : 1.0)
                .animation(.easeInOut(duration: 0.20), value: configuration.isPressed)
                .opacity(configuration.isPressed ? 0.5 : 0.95)
        }
    }
}

private struct MovieCaptureButton: View {
    private let action: (Bool) -> Void
    private let lineWidth = CGFloat(4.0)

    @State private var isRecording = false

    init(action: @escaping (Bool) -> Void) {
        self.action = action
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: lineWidth)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.gray.opacity(0.7), Color.white.opacity(0.8)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    isRecording.toggle()
                }
                action(isRecording)
            } label: {
                GeometryReader { geometry in
                    RoundedRectangle(cornerRadius: geometry.size.width / (isRecording ? 4.0 : 2.0))
                        .inset(by: lineWidth * 1.2)
                        .fill(.red)
                        .scaleEffect(isRecording ? 0.6 : 1.0)
                }
            }
            .buttonStyle(NoFadeButtonStyle())
        }
    }

    struct NoFadeButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
        }
    }
}
