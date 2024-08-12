//
//  DataTypes.swift
//  iCameraV3
//
//  Created by Ima Da Costa on 03/08/2024.
//

import Foundation
import AVFoundation

// MARK: - Camera Status

/// An enumeration that describes the current status of the camera.
enum CameraStatus: Equatable {
    case unknown
    case unauthorized
    case running
    case failed(Error)
    case interrupted
    case ready
    
    static func ==(lhs: CameraStatus, rhs: CameraStatus) -> Bool {
        switch (lhs, rhs) {
        case (.unauthorized, .unauthorized),
             (.interrupted, .interrupted),
             (.ready, .ready):
            return true
        case (.failed(let lhsError), .failed(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
}

// MARK: - Capture Activity

/// An enumeration that defines the activity states the capture service supports.
///
/// This type provides feedback to the UI regarding the active status of the `CaptureService` actor.
enum CaptureActivity: Equatable {
    case idle
    /// A status that indicates the capture service is performing photo capture.
    case photoCapture(willCapture: Bool = false, isLivePhoto: Bool = false)
    /// A status that indicates the capture service is performing movie capture.
    case movieCapture(duration: TimeInterval = 0.0)
    
    var isLivePhoto: Bool {
        if case .photoCapture(_, let isLivePhoto) = self {
            return isLivePhoto
        }
        return false
    }
    
    var willCapture: Bool {
        if case .photoCapture(let willCapture, _) = self {
            return willCapture
        }
        return false
    }
    
    var currentTime: TimeInterval {
        if case .movieCapture(let duration) = self {
            return duration
        }
        return .zero
    }
    
    var isRecording: Bool {
        if case .movieCapture = self {
            return true
        }
        return false
    }
}

// MARK: - Captured Media Types

/// A structure that represents a captured photo.
struct Photo: Sendable {
    let data: Data
    let isProxy: Bool
    let livePhotoMovieURL: URL?
}

/// A structure that contains the uniform type identifier and movie URL.
struct Movie: Sendable {
    /// The temporary location of the file on disk.
    let url: URL
}

// MARK: - Photo Features

@Observable
/// An object that stores the state of a person's enabled photo features.
class PhotoFeatures {
    var isFlashEnabled = false
    var isLivePhotoEnabled = false
    var qualityPrioritization: QualityPrioritization = .quality
    
    var current: EnabledPhotoFeatures {
        .init(isFlashEnabled: isFlashEnabled,
              isLivePhotoEnabled: isLivePhotoEnabled,
              qualityPrioritization: qualityPrioritization)
    }
}

/// A structure representing the enabled photo features.
struct EnabledPhotoFeatures {
    let isFlashEnabled: Bool
    let isLivePhotoEnabled: Bool
    let qualityPrioritization: QualityPrioritization
    var flashMode: AVCaptureDevice.FlashMode = .auto
    var hdrEnabled: Bool = false
    var photoQuality: Int = 100 // Assuming quality is a percentage
    var aspectRatio: PhotoAspectRatio = .fourByThree
    var exposureValue: Double = 0.0
    var timer: TimerMode = .off
    var selectedFilter: Filter = .none
    var macroMode: Bool = false
    var depthEnabled: Bool = false
    var livePhotosMode: Bool = false
    var format: CameraSettings.Format = .jpeg
    var nightModeEnabled: Bool = false
    var smartHDR: Bool = false
    var appleProRAW: Bool = false
    var portraitLightingEffect: String = "Natural Light"
    var depthControl: Double = 0.0
    var lightingIntensity: Double = 0.0
}
    
// MARK: - Capture Capabilities

/// A structure that represents the capture capabilities of `CaptureService` in
/// its current configuration.
struct CaptureCapabilities {
    let isFlashSupported: Bool
    let isLivePhotoCaptureSupported: Bool
    let isHDRSupported: Bool
    
    init(isFlashSupported: Bool = false,
         isLivePhotoCaptureSupported: Bool = false,
         isHDRSupported: Bool = false) {
        
        self.isFlashSupported = isFlashSupported
        self.isLivePhotoCaptureSupported = isLivePhotoCaptureSupported
        self.isHDRSupported = isHDRSupported
    }
    
    static let unknown = CaptureCapabilities()
}

// MARK: - Quality Prioritization

/// An enumeration that defines the prioritization for capture quality.
enum QualityPrioritization: Int, Identifiable, CaseIterable, CustomStringConvertible {
    var id: Self { self }
    case speed = 1
    case balanced
    case quality
    
    var description: String {
        switch self {
        case .speed:
            return "Speed"
        case .balanced:
            return "Balanced"
        case .quality:
            return "Quality"
        }
    }
}

// MARK: - Capture Modes

/// An enumeration that defines the modes of capture.
enum CaptureMode: String, Identifiable, CaseIterable {
    var id: Self { self }
    
    /// A mode that enables photo capture.
    case photo
    /// A mode that enables video capture.
    case video
    
    var systemName: String {
        switch self {
        case .photo:
            return "camera.fill"
        case .video:
            return "video.fill"
        }
    }
}

// MARK: - Camera Error

/// An enumeration that defines various errors that can occur in the camera system.
enum CameraError: Error {
    case videoDeviceUnavailable
    case audioDeviceUnavailable
    case addInputFailed
    case addOutputFailed
    case setupFailed
    case deviceChangeFailed
}

// MARK: - Preview Source
enum PreviewSourceType {
    case camera
    case test
}

// MARK: - Manual Controls
struct ManualControls {
    var iso: Float = 0.0
    var shutterSpeed: Float = 0.0
    var whiteBalance: Float = 0.0
    var focus: CGPoint = .zero
}

// MARK: - Photo Saving Options
struct PhotoSaveOptions {
    var flashMode: AVCaptureDevice.FlashMode
    var hdrMode: Bool
    var photoQuality: Int
    var aspectRatio: PhotoAspectRatio
    var exposureValue: Double
    var timer: TimerMode
    var selectedFilter: Filter
    var macroMode: Bool
    var depthEnabled: Bool
    var livePhotosMode: Bool
    var format: PhotoFormat // Ensure this aligns with `CameraSettings.Format`
    var nightModeEnabled: Bool
    var smartHDR: Bool
    var appleProRAW: Bool
    var portraitLightingEffect: String
    var depthControl: Double
    var lightingIntensity: Double
    var isFlashEnabled: Bool
    var isLivePhotoEnabled: Bool
    var qualityPrioritization: QualityPrioritization
}


// MARK: - Photo Formats
enum PhotoFormat {
    case jpeg
    case heif
    case proRAW

}

enum LocationError: Error {
    case unauthorized
    case noLocationFound
}

enum PhotoCaptureError: Error {
    case noPhotoData
}
