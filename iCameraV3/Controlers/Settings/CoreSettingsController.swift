//
//  CoreSettingsController.swift
//  iCamera
//
//  Created by Ima Da Costa on 24/06/2024.
//

import Foundation
import AVFoundation
import Combine

class CoreSettingsController: ObservableObject {
    @Published var flashMode: AVCaptureDevice.FlashMode = .auto
    @Published var nightMode: Bool = false
    @Published var livePhotosMode: Bool = false
    @Published var aspectRatio: PhotoAspectRatio = .fourByThree
    @Published var exposureValue: Double = 0.0
    @Published var timer: TimerMode = .off
    @Published var selectedFilter: Filter = .none
    @Published var photographicStyle: PhotographicStyle = .standard
    @Published var macroMode: Bool = false
    @Published var portraitLightingEffect: String = "Natural Light"
    @Published var depthControl: Double = 0.0
    @Published var lightingIntensity: Double = 0.0
    @Published var videoResolution: String = "1080p HD at 30 fps"
    @Published var hdrVideo: Bool = false
    @Published var cinematicMode: Bool = false
    @Published var slowMotion: String = "1080p at 120 fps"
    @Published var timeLapse: String = "Standard"
    @Published var audioZoom: Bool = false
    @Published var actionMode: Bool = false
    @Published var appleProRAW: Bool = false
    @Published var proResVideo: Bool = false
    @Published var format: String = "High Efficiency"
    @Published var grid: Bool = false
    @Published var mirrorFrontCamera: Bool = false
    @Published var smartHDR: Bool = false
    @Published var lensCorrection: Bool = false
    @Published var sceneDetection: Bool = false
    @Published var prioritizeFasterShooting: Bool = false
    @Published var recordStereoSound: Bool = false
    @Published var macroControl: Bool = false
    @Published var keepSettings: Bool = false
    
    @Published var burstInterval: BurstInterval = .twoSeconds
    @Published var burstCount: Double = 5
}

enum PhotoAspectRatio: String, CaseIterable, Identifiable {
    case square = "1:1"
    case fourByThree = "4:3"
    case sixteenByNine = "16:9"

    var id: String { self.rawValue }
}

// ... Other Enums Remain the Same ...
