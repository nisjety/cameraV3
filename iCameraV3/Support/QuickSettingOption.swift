//
//  QuickSettingOption.swift
//  iCameraV3
//
//  Created by Ima Da Costa on 07/08/2024.
//


import SwiftUI
import AVFoundation

struct QuickSettingOption: Identifiable {
    let name: String
    let icon: String
    let action: () -> Void
    let id = UUID()
    var conflictsWith: [String] = []
    var active: Bool = false
    var showIndicator: Bool = false


    // Static method to provide a list of options
    struct Options {
        static let all: [QuickSettingOption] = [
            QuickSettingOption(
                name: "Quality",
                icon: "arrow.up.arrow.down.circle.fill",
                action: { qualityPrioritization() },
                conflictsWith: ["ProRAW"]
            ),
            QuickSettingOption(
                name: "Torch",
                icon: "sun.max.fill",
                action: { toggleTorch() },
                conflictsWith: ["Night Mode"]
            ),
            QuickSettingOption(
                name: "Night Mode",
                icon: "moon.stars.fill",
                action: { toggleNightMode() },
                conflictsWith: ["Torch"]
            ),
            QuickSettingOption(
                name: "Macro",
                icon: "camera.macro",
                action: { toggleMacroMode() },
                conflictsWith: ["Panorama"]
            ),
            QuickSettingOption(
                name: "Live Photo",
                icon: "livephoto",
                action: { toggleLivePhoto() },
                conflictsWith: ["ProRAW"]
            ),
            QuickSettingOption(
                name: "ProRAW",
                icon: "photo.on.rectangle",
                action: { toggleProRAW() },
                conflictsWith: ["Live Photo"]
            ),
            QuickSettingOption(
                name: "HDR Video",
                icon: "camera.aperture",
                action: { toggleHDRVideo() }
            ),
            QuickSettingOption(
                name: "Flash",
                icon: "bolt.fill",
                action: { toggleFlash() }
            ),
            QuickSettingOption(
                name: "Timer",
                icon: "timer",
                action: { toggleTimer() }
            ),
            QuickSettingOption(
                name: "Aspect Ratio",
                icon: "aspectratio.fill",
                action: { toggleAspectRatio() }
            ),
            QuickSettingOption(
                name: "Filters",
                icon: "wand.and.stars",
                action: { toggleFilters() }
            ),
            QuickSettingOption(
                name: "Styles",
                icon: "paintbrush.fill",
                action: { toggleStyles() }
            ),
            QuickSettingOption(
                name: "Burst Mode",
                icon: "burst",
                action: { toggleBurstMode() }
            ),
            QuickSettingOption(
                name: "AI",
                icon: "brain.head.profile",
                action: { toggleAI() }
            )
        ]
    }

    // Implement toggle functions using modern SwiftUI and AVFoundation
    static func toggleTorch() {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else {
            print("Torch not available")
            return
        }
        
        do {
            try device.lockForConfiguration()
            device.torchMode = device.torchMode == .on ? .off : .on
            device.unlockForConfiguration()
            print("Torch toggled")
        } catch {
            print("Failed to toggle torch: \(error)")
        }
    }
    
    static var isNightModeEnabled = false

    static func toggleNightMode() {
        isNightModeEnabled.toggle()
        print("Night Mode toggled: \(isNightModeEnabled ? "On" : "Off")")
    }

    static var isMacroModeEnabled = false

    static func toggleMacroMode() {
        isMacroModeEnabled.toggle()
        print("Macro Mode toggled: \(isMacroModeEnabled ? "On" : "Off")")
    }

    static var isLivePhotoEnabled = false

    static func toggleLivePhoto() {
        isLivePhotoEnabled.toggle()
        print("Live Photo toggled: \(isLivePhotoEnabled ? "On" : "Off")")
    }

    static var isProRAWEnabled = false

    static func toggleProRAW() {
        isProRAWEnabled.toggle()
        print("ProRAW toggled: \(isProRAWEnabled ? "On" : "Off")")
    }

    static var isHDRVideoEnabled = false

    static func toggleHDRVideo() {
        isHDRVideoEnabled.toggle()
        print("HDR Video toggled: \(isHDRVideoEnabled ? "On" : "Off")")
    }

    static func toggleFlash() {
            print("Flash toggled")
        }
    /* This method should belong to a class that conforms to AVCapturePhotoCaptureDelegate
    static func toggleFlash(photoOutput: AVCapturePhotoOutput, delegate: AVCapturePhotoCaptureDelegate) {
        // Toggle flash mode between off and on
        let currentFlashMode: AVCaptureDevice.FlashMode = .off // This should be derived from actual settings or state
        
        // Capture a photo with the updated flash settings
        let photoSettings = AVCapturePhotoSettings()
        photoSettings.flashMode = currentFlashMode == .on ? .off : .on
        photoOutput.capturePhoto(with: photoSettings, delegate: delegate)
        
        print("Flash toggled to: \(photoSettings.flashMode == .on ? "On" : "Off")")
    }
*/

    static var isTimerEnabled = false

    static func toggleTimer() {
        isTimerEnabled.toggle()
        print("Timer toggled: \(isTimerEnabled ? "On" : "Off")")
    }

    static var currentAspectRatio: String = "4:3"

    static func toggleAspectRatio() {
        currentAspectRatio = currentAspectRatio == "4:3" ? "16:9" : "4:3"
        print("Aspect Ratio toggled to: \(currentAspectRatio)")
    }

    static var currentFilter: String = "None"

    static func toggleFilters() {
        currentFilter = currentFilter == "None" ? "Sepia" : "None"
        print("Filter toggled to: \(currentFilter)")
    }

    static var currentStyle: String = "Standard"

    static func toggleStyles() {
        currentStyle = currentStyle == "Standard" ? "Cinematic" : "Standard"
        print("Style toggled to: \(currentStyle)")
    }

    static var isBurstModeEnabled = false

    static func toggleBurstMode() {
        isBurstModeEnabled.toggle()
        print("Burst Mode toggled: \(isBurstModeEnabled ? "On" : "Off")")
    }

    static var isAIEnabled = false

    static func toggleAI() {
        isAIEnabled.toggle()
        print("AI toggled: \(isAIEnabled ? "On" : "Off")")
    }

    static func qualityPrioritization() {
        print("Quality prioritization toggled")
    }
}

