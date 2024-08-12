import SwiftUI
import AVFoundation

struct CaptureControls: View {
    @ObservedObject var camera: CameraModel

    @State private var settingsOptions: [QuickSettingOption] = QuickSettingOption.Options.all
    @State private var selectedMode: Mode = Mode.CameraMode.modes.first { $0.name == "Photo" }!
    @State private var componentSpacing: CGFloat = 144
    @State private var cameraChoiceOffset: CGFloat = 4 // Offset for CameraTypeChoice
    @State private var toolbarOffset: CGFloat = 8 // Offset for QuickSettingsToolbar
    @State private var hstackOffset: CGFloat = 22 // New offset for HStack

    var body: some View {
        VStack {
            // Adding a Rectangle without padding
            Rectangle()
                .frame(height: 2)
                .frame(maxWidth: .infinity) // Ensure it occupies the full width
                .overlay(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.gray.opacity(0.9), Color.white.opacity(1.5), Color.gray.opacity(0.9)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 10) {
                    CameraTypeChoice(selectedMode: $selectedMode)
                        .offset(y: cameraChoiceOffset) // Apply offset to CameraTypeChoice

                    HStack {
                        ThumbnailButton(camera: camera) // Replacing the gallery button

                        CaptureButton(camera: camera, selectedMode: $selectedMode)
                            .padding(.horizontal, abs(componentSpacing) / 2) // Adjust capture button size

                        SwitchCameraButton(camera: camera) // Replacing the switch camera button
                    }
                    .offset(y: hstackOffset) // Apply offset to HStack

                    // Quick settings toolbar
                    QuickSettingsToolbar(settingsOptions: $settingsOptions) // Pass the options as a binding
                        .offset(y: toolbarOffset) // Use offset to adjust position
                }
                .padding(.horizontal) // Add padding to the entire VStack
            }
        }
        .frame(height: 138)
        .background(Color.gray.opacity(0.1))
        .scrollBounceBehavior(.basedOnSize) // Optional: set a background to see the controls clearly
    }
}

// Preview Provider should be outside the main struct
struct CaptureControls_Previews: PreviewProvider {
    static var previews: some View {
        CaptureControls(camera: PreviewCameraModel())
            .previewDevice("iPhone 15 Pro")
            .previewDisplayName("iPhone 15 Pro")
    }
}
