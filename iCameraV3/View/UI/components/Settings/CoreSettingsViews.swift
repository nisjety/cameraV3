//
//  CoreSettingsView.swift
//  iCamera
//
//  Created by Ima Da Costa on 24/06/2024.
//

import SwiftUI
import AVFoundation

struct CoreSettingsView: View {
    @ObservedObject var settingsController: CoreSettingsController

    var body: some View {
        Form {
            Section(header: Text("Photo Mode Settings")) {
                Picker("Flash Mode", selection: $settingsController.flashMode) {
                    Text("Auto").tag(AVCaptureDevice.FlashMode.auto)
                    Text("On").tag(AVCaptureDevice.FlashMode.on)
                    Text("Off").tag(AVCaptureDevice.FlashMode.off)
                }
                Toggle(isOn: $settingsController.nightMode) {
                    Text("Night Mode")
                }
                Toggle(isOn: $settingsController.livePhotosMode) {
                    Text("Live Photos")
                }
                Picker("Aspect Ratio", selection: $settingsController.aspectRatio) {
                    Text("Square (1:1)").tag(PhotoAspectRatio.square)
                    Text("4:3").tag(PhotoAspectRatio.fourByThree)
                    Text("16:9").tag(PhotoAspectRatio.sixteenByNine)
                }
                HStack {
                    Text("Exposure")
                    Slider(value: $settingsController.exposureValue, in: -2...2, step: 0.1)
                    Text("\(settingsController.exposureValue, specifier: "%.1f")")
                }
                Picker("Timer", selection: $settingsController.timer) {
                    Text("Off").tag(TimerMode.off)
                    Text("3 seconds").tag(TimerMode.threeSeconds)
                    Text("10 seconds").tag(TimerMode.tenSeconds)
                }
                Picker("Filter", selection: $settingsController.selectedFilter) {
                    Text("None").tag(Filter.none)
                    Text("Vivid").tag(Filter.vivid)
                    Text("Dramatic").tag(Filter.dramatic)
                    Text("Mono").tag(Filter.mono)
                }
                Picker("Photographic Style", selection: $settingsController.photographicStyle) {
                    Text("Standard").tag(PhotographicStyle.standard)
                    Text("Rich Contrast").tag(PhotographicStyle.richContrast)
                    Text("Vibrant").tag(PhotographicStyle.vibrant)
                    Text("Warm").tag(PhotographicStyle.warm)
                    Text("Cool").tag(PhotographicStyle.cool)
                }
                Toggle(isOn: $settingsController.macroMode) {
                    Text("Macro Mode")
                }
                Picker("Burst Interval", selection: $settingsController.burstInterval) {
                    Text("2 seconds").tag(BurstInterval.twoSeconds)
                    Text("3 seconds").tag(BurstInterval.threeSeconds)
                    Text("5 seconds").tag(BurstInterval.fiveSeconds)
                    Text("7 seconds").tag(BurstInterval.sevenSeconds)
                    Text("10 seconds").tag(BurstInterval.tenSeconds)
                }
                HStack {
                    Text("Burst Count")
                    Slider(value: $settingsController.burstCount, in: 1...10, step: 1)
                    Text("\(Int(settingsController.burstCount))")
                }
            }
            
            Section(header: Text("Portrait Mode Settings")) {
                Picker("Lighting Effect", selection: $settingsController.portraitLightingEffect) {
                    Text("Natural Light").tag("Natural Light")
                    Text("Studio Light").tag("Studio Light")
                    Text("Contour Light").tag("Contour Light")
                    Text("Stage Light").tag("Stage Light")
                    Text("Stage Light Mono").tag("Stage Light Mono")
                    Text("High-Key Light Mono").tag("High-Key Light Mono")
                }
                HStack {
                    Text("Depth Control")
                    Slider(value: $settingsController.depthControl, in: 0...1, step: 0.1)
                    Text("\(settingsController.depthControl, specifier: "%.1f")")
                }
                HStack {
                    Text("Lighting Intensity")
                    Slider(value: $settingsController.lightingIntensity, in: 0...1, step: 0.1)
                    Text("\(settingsController.lightingIntensity, specifier: "%.1f")")
                }
            }
            
            Section(header: Text("Video Mode Settings")) {
                Picker("Resolution and Frame Rate", selection: $settingsController.videoResolution) {
                    Text("720p HD at 30 fps").tag("720p HD at 30 fps")
                    Text("1080p HD at 30 fps").tag("1080p HD at 30 fps")
                    Text("1080p HD at 60 fps").tag("1080p HD at 60 fps")
                    Text("4K at 24 fps").tag("4K at 24 fps")
                    Text("4K at 30 fps").tag("4K at 30 fps")
                    Text("4K at 60 fps").tag("4K at 60 fps")
                }
                Toggle(isOn: $settingsController.hdrVideo) {
                    Text("HDR Video")
                }
                Toggle(isOn: $settingsController.cinematicMode) {
                    Text("Cinematic Mode")
                }
                Picker("Slow Motion", selection: $settingsController.slowMotion) {
                    Text("1080p at 120 fps").tag("1080p at 120 fps")
                    Text("1080p at 240 fps").tag("1080p at 240 fps")
                }
                Picker("Time-Lapse", selection: $settingsController.timeLapse) {
                    Text("Standard").tag("Standard")
                    Text("Low Light").tag("Low Light")
                    Text("Night Mode").tag("Night Mode")
                }
                Toggle(isOn: $settingsController.audioZoom) {
                    Text("Audio Zoom")
                }
                Toggle(isOn: $settingsController.actionMode) {
                    Text("Action Mode")
                }
            }
            
            Section(header: Text("ProRAW and ProRes Settings")) {
                Toggle(isOn: $settingsController.appleProRAW) {
                    Text("Apple ProRAW")
                }
                Toggle(isOn: $settingsController.proResVideo) {
                    Text("ProRes Video")
                }
            }
            
            Section(header: Text("Additional Camera Settings")) {
                Picker("Format", selection: $settingsController.format) {
                    Text("High Efficiency (HEIF/HEVC)").tag("High Efficiency")
                    Text("Most Compatible (JPEG/H.264)").tag("Most Compatible")
                }
                Toggle(isOn: $settingsController.grid) {
                    Text("Grid")
                }
                Toggle(isOn: $settingsController.mirrorFrontCamera) {
                    Text("Mirror Front Camera")
                }
                Toggle(isOn: $settingsController.smartHDR) {
                    Text("Smart HDR")
                }
                Toggle(isOn: $settingsController.lensCorrection) {
                    Text("Lens Correction")
                }
                Toggle(isOn: $settingsController.sceneDetection) {
                    Text("Scene Detection")
                }
                Toggle(isOn: $settingsController.prioritizeFasterShooting) {
                    Text("Prioritize Faster Shooting")
                }
                Toggle(isOn: $settingsController.recordStereoSound) {
                    Text("Record Stereo Sound")
                }
                Toggle(isOn: $settingsController.macroControl) {
                    Text("Macro Control")
                }
                Toggle(isOn: $settingsController.keepSettings) {
                    Text("Keep Settings")
                }
            }
        }
    }
}

struct CoreSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        CoreSettingsView(settingsController: CoreSettingsController())
    }
}

// Enums for TimerMode, Filter, PhotographicStyle, and BurstInterval remain unchanged

enum AspectRatio: String, CaseIterable, Identifiable {
    case square = "1:1"
    case fourByThree = "4:3"
    case sixteenByNine = "16:9"

    var id: String { self.rawValue }
}

enum TimerMode: Double, CaseIterable, Identifiable {
    case off = 0.0
    case threeSeconds = 3.0
    case tenSeconds = 10.0

    var id: Double { self.rawValue }
}

enum Filter: String, CaseIterable, Identifiable {
    case none = "None"
    case vivid = "Vivid"
    case dramatic = "Dramatic"
    case mono = "Mono"

    var id: String { self.rawValue }
}

enum PhotographicStyle: String, CaseIterable, Identifiable {
    case standard = "Standard"
    case richContrast = "Rich Contrast"
    case vibrant = "Vibrant"
    case warm = "Warm"
    case cool = "Cool"

    var id: String { self.rawValue }
}

enum BurstInterval: Double, CaseIterable, Identifiable {
    case twoSeconds = 2.0
    case threeSeconds = 3.0
    case fiveSeconds = 5.0
    case sevenSeconds = 7.0
    case tenSeconds = 10.0

    var id: Double { self.rawValue }
}
