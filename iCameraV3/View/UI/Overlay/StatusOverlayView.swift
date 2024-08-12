//
//  StatusOverlayView.swift
//  iCameraV3
//
//  Created by Ima Da Costa on 03/08/2024.
//

import SwiftUI

/// A view that presents a status message over the camera user interface.
struct StatusOverlayView: View {
    
    @State private var showAlert = false
    let status: CameraStatus
    let handled: [CameraStatus] = [.unauthorized, .interrupted, .failed(NSError(domain: "", code: 0, userInfo: nil))]
    var retryAction: () -> Void // Closure for retrying the camera setup
    
    var body: some View {
        ZStack {
            // Dimming view if there's a relevant status.
            if handled.contains(where: { $0 == status }) {
                Rectangle()
                    .fill(Color.black.opacity(0.5))
                    .edgesIgnoringSafeArea(.all)
                    .onAppear {
                        showAlert = true
                    }
            }
        }
        .alert(isPresented: $showAlert) {
            getAlert(for: status)
        }
    }
    
    /// Returns an alert for the given camera status.
    private func getAlert(for status: CameraStatus) -> Alert {
        switch status {
        case .unauthorized:
            return Alert(
                title: Text("Camera Access Needed"),
                message: Text("You haven't authorized AVCam to use the camera or microphone. Change these settings in Settings -> Privacy & Security."),
                primaryButton: .default(Text("Open Settings")) {
                    openSettings()
                },
                secondaryButton: .cancel(Text("Cancel")) {
                    handleCancelAction()
                }
            )
        case .failed:
            return Alert(
                title: Text("Camera Error"),
                message: Text("The camera failed to start. Please try relaunching the app."),
                dismissButton: .default(Text("Retry")) {
                    retryAction() // Retry the camera setup
                }
            )
        case .interrupted:
            return Alert(
                title: Text("Camera Interrupted"),
                message: Text("The camera was interrupted by higher-priority media processing."),
                dismissButton: .default(Text("OK")) {
                    // Handle OK action if needed
                }
            )
        default:
            return Alert(title: Text("Unknown Status"), message: Text("An unknown status occurred."))
        }
    }
    
    private func handleCancelAction() {
        // Action to handle the cancel button
        exit(0) // Close the app
    }
    
    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}

#Preview {
    StatusOverlayView(status: .unauthorized, retryAction: {
        print("Retrying camera setup...")
        // Add retry logic here
    })
        .background(Color.black)
        .previewDevice("iPhone 15 Pro")
        .previewDisplayName("iPhone 15 Pro")
}
