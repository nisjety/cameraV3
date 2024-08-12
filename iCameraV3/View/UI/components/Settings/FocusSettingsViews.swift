//
//  FocusSettingsView.swift
//  iCamera
//
//  Created by Ima Da Costa on 23/06/2024.
//

import SwiftUI

struct FocusSettingsView: View {
    @ObservedObject var focusSettingsController: FocusSettingsController
    
    var body: some View {
        Form {
            Section(header: Text("Focus Mode")) {
                Picker("Focus Mode", selection: $focusSettingsController.focusMode) {
                    Text("Auto Focus").tag(FocusMode.auto)
                    Text("Manual Focus").tag(FocusMode.manual)
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            if focusSettingsController.focusMode == .manual {
                Section(header: Text("Manual Focus Settings")) {
                    Toggle("Real-Time Recalibration", isOn: $focusSettingsController.isRealTimeRecalibrationEnabled)
                    
                    HStack {
                        Text("Zoom Level")
                        Slider(value: $focusSettingsController.zoomLevel, in: 1...15, step: 0.1)
                            .disabled(!focusSettingsController.isZoomEnabled)
                    }
                    
                    Toggle("Enable Zoom", isOn: $focusSettingsController.isZoomEnabled)
                }
            }
        }
        .navigationBarTitle("Focus Settings")
    }
}

struct FocusSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        FocusSettingsView(focusSettingsController: FocusSettingsController())
    }
}
