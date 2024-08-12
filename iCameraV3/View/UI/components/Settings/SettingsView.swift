//
//  SettingsView.swift
//  iCamera
//
//  Created by Ima Da Costa on 23/06/2024.
//

import SwiftUI
import AVFoundation

struct SettingsView: View {
    @Binding var isPresented: Bool
    @ObservedObject var settingsController: CoreSettingsController
    @ObservedObject var focusSettingsController: FocusSettingsController
    @ObservedObject var aiSettingsController: AISettingsController

    var body: some View {
        NavigationView {
            TabView {
                CoreSettingsView(settingsController: settingsController)
                    .tabItem {
                        Label("Core", systemImage: "camera")
                    }
                
                IntermediateSettingsView()
                    .tabItem {
                        Label("Intermediate", systemImage: "gearshape")
                    }
                
                AdvancedSettingsView()
                    .tabItem {
                        Label("Advanced", systemImage: "wrench")
                    }
                
                ExpertSettingsView()
                    .tabItem {
                        Label("Expert", systemImage: "star")
                    }
                
                FocusSettingsView(focusSettingsController: focusSettingsController)
                    .tabItem {
                        Label("Focus", systemImage: "scope")
                    }
                
                AISettingsView(aiSettingsController: aiSettingsController)
                    .tabItem {
                        Label("AI", systemImage: "brain.head.profile")
                    }
            }
            .navigationBarTitle("Settings")
            .navigationBarItems(trailing: Button("Done") {
                isPresented = false
            })
        }
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 10)
        .padding(10)
        .frame(height: 820)
        .offset(y:30)
    }
}

struct SettingsView_Previews: PreviewProvider {
    @State static var isPresented = true
    static var previews: some View {
        SettingsView(isPresented: $isPresented,
                     settingsController: CoreSettingsController(),
                     focusSettingsController: FocusSettingsController(),
                     aiSettingsController: AISettingsController())
    }
}
