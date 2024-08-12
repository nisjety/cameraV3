//
//  TopControls.swift
//  iCameraV3
//
//  Created by Ima Da Costa on 07/08/2024.
//

import SwiftUI

struct TopControls: View {
    @State private var isShowingSettings = false
    @ObservedObject var camera: CameraModel // Assume camera is passed as part of the view

    @State private var settingSpacing: CGFloat = 20
    @State private var settingOffset: CGFloat = 8

    var body: some View {
        HStack(spacing: settingSpacing) {
            DropDownMenu()
            Spacer()
            SettingsButton(isShowingSettings: $isShowingSettings)
        }
        .padding()
        .offset(x: settingOffset) // Apply horizontal offset
        .background(Color(.systemBackground).opacity(0.95))
        .fullScreenCover(isPresented: $isShowingSettings) {
            // Pass the controllers you need for the settings view
            SettingsView(
                isPresented: $isShowingSettings,
                settingsController: CoreSettingsController(),
                focusSettingsController: FocusSettingsController(),
                aiSettingsController: AISettingsController()
            )
            .background(Color.black.opacity(0.5))
            .transition(.move(edge: .top))
        }
    }
}

struct TopControls_Previews: PreviewProvider {
    static var previews: some View {
        TopControls(camera: PreviewCameraModel())
            .previewLayout(.sizeThatFits)
    }
}
