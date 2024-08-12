//
//  CameraSettings.swift
//  iCameraV3
//
//  Created by Ima Da Costa on 07/08/2024.
//

import Foundation
import AVFoundation

struct CameraSettings {
    
    enum Resolution: String, CaseIterable {
        case hd1080 = "1080p"
        case hd4K = "4K"
    }

    enum FrameRate: Int, CaseIterable {
        case fps24 = 24
        case fps30 = 30
        case fps60 = 60
    }

    enum Format: String, CaseIterable {
        case jpeg = "JPEG"
        case heif = "HEIF"
        case proRAW = "ProRAW"
        case h264 = "H.264"
        case hevc = "HEVC"
        case proRes = "ProRes"
    }

    var resolution: Resolution
    var frameRate: FrameRate
    var format: Format
    var hdrEnabled: Bool
    var nightModeEnabled: Bool
    var cinematicModeEnabled: Bool
    var macroModeEnabled: Bool

    static var defaultSettings: CameraSettings {
        CameraSettings(
            resolution: .hd1080,
            frameRate: .fps30,
            format: .jpeg,
            hdrEnabled: false,
            nightModeEnabled: false,
            cinematicModeEnabled: false,
            macroModeEnabled: false
        )
    }
}
