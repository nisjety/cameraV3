//
//  AISettingsViews.swift
//  iCamera
//
//  Created by Ima Da Costa on 23/06/2024.
//

import SwiftUI

struct AISettingsView: View {
    @ObservedObject var aiSettingsController: AISettingsController
    
    
    var body: some View {
        Form {
            Section(header: Text("AI Features")) {
                Toggle("Face Detection", isOn: $aiSettingsController.isFaceDetectionEnabled)
                
                Toggle("AI Scene Recognition", isOn: $aiSettingsController.isAISceneRecognitionEnabled)
            }
            
            if aiSettingsController.isFaceDetectionEnabled {
                Section(header: Text("Face Detection Settings")) {
                    Toggle("Auto Focus on Faces", isOn: $aiSettingsController.isAutoFocusOnFacesEnabled)
                }
            }
        }
        .navigationBarTitle("AI Settings")
    }
}

struct AISettingsView_Previews: PreviewProvider {
    static var previews: some View {
        AISettingsView(aiSettingsController: AISettingsController())
    }
}
