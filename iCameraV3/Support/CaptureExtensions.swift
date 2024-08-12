//
//  CaptureExtensions.swift
//  iCameraV3
//
//  Created by Ima Da Costa on 08/08/2024.
//

import Foundation
import CoreVideo
import AVFoundation

// MARK: - CMVideoDimensions Extensions

/// Extensions to add Equatable and Comparable conformance to CMVideoDimensions.
extension CMVideoDimensions {

    /// A zero value for CMVideoDimensions.
    static let zero = CMVideoDimensions(width: 0, height: 0)
    
    /// Checks equality between two CMVideoDimensions.
    public static func == (lhs: CMVideoDimensions, rhs: CMVideoDimensions) -> Bool {
        lhs.width == rhs.width && lhs.height == rhs.height
    }
    
    /// Compares two CMVideoDimensions.
    public static func < (lhs: CMVideoDimensions, rhs: CMVideoDimensions) -> Bool {
        lhs.width < rhs.width && lhs.height < rhs.height
    }
}

// MARK: - AVCaptureDevice Extensions

extension AVCaptureDevice {
    

    /// Retrieves the active format's 10-bit variant if available.
    var activeFormat10BitVariant: AVCaptureDevice.Format? {
        formats.filter {
            $0.maxFrameRate == activeFormat.maxFrameRate &&
            $0.formatDescription.dimensions == activeFormat.formatDescription.dimensions
        }
        .first(where: { $0.isTenBitFormat })
    }

    /// Checks if the device supports ProRAW capture.
    var isProRAWSupported: Bool {
        formats.contains { format in
            format.supportedColorSpaces.contains(.P3_D65)
        }
    }
    
    /// Checks if the device supports cinematic video stabilization.
    var isCinematicVideoStabilizationSupported: Bool {
        activeFormat.isVideoStabilizationModeSupported(.cinematic)
    }
    
    
    /// Configures the device for HDR video capture.
    func configureForHDRVideoCapture() throws {
        if let hdrFormat = activeFormat10BitVariant {
            try lockForConfiguration()
            activeFormat = hdrFormat
            unlockForConfiguration()
        }
    }
    
    /// Configures the device for depth data capture.
    func configureForDepthDataCapture() throws {
        if let depthFormat = formats.first(where: { !$0.supportedDepthDataFormats.isEmpty }) {
            try lockForConfiguration()
            activeFormat = depthFormat
            unlockForConfiguration()
        }
    }
}

// MARK: - AVCaptureDevice.Format Extensions

extension AVCaptureDevice.Format {
    
    /// Checks if the format is a 10-bit format.
    var isTenBitFormat: Bool {
        formatDescription.mediaSubType.rawValue == kCVPixelFormatType_420YpCbCr10BiPlanarVideoRange
    }
    
    /// Retrieves the maximum frame rate for the format.
    var maxFrameRate: Double {
        videoSupportedFrameRateRanges.last?.maxFrameRate ?? 0
    }
    
    /// Checks if the format supports depth data.
    var supportsDepthData: Bool {
        !supportedDepthDataFormats.isEmpty
    }
    
    /// Checks if the format supports ProRAW.
    var supportsProRAW: Bool {
        supportedColorSpaces.contains(.P3_D65)
    }
}

// MARK: - AVCapturePhotoSettings Extensions

extension AVCapturePhotoSettings {
    /// Configures the photo settings for HDR capture.
    static func hdrSettings() -> AVCapturePhotoSettings {
        let settings = AVCapturePhotoSettings()
        settings.maxPhotoDimensions = AVCapturePhotoOutput().maxPhotoDimensions
        // Remove the following line since HDR photo enabling might be controlled elsewhere
        // settings.isHDRPhotoEnabled = true
        return settings
    }

    /// Configures the photo settings for ProRAW capture.
    static func proRAWSettings() -> AVCapturePhotoSettings {
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
        settings.maxPhotoDimensions = AVCapturePhotoOutput().maxPhotoDimensions
        // Remove or customize the RAW setting based on current compatibility
        // settings.isRawPhotoEnabled = true
        return settings
    }
}


// MARK: - EnabledPhotoFeatures Extensions

extension EnabledPhotoFeatures {
    init(from options: PhotoSaveOptions) {
        self.init(
            isFlashEnabled: options.isFlashEnabled,
            isLivePhotoEnabled: options.isLivePhotoEnabled,
            qualityPrioritization: options.qualityPrioritization,
            flashMode: options.flashMode,
            hdrEnabled: options.hdrMode,
            photoQuality: options.photoQuality,
            aspectRatio: options.aspectRatio,
            exposureValue: options.exposureValue,
            timer: options.timer,
            selectedFilter: options.selectedFilter,
            macroMode: options.macroMode,
            depthEnabled: options.depthEnabled,
            livePhotosMode: options.livePhotosMode,
            format: CameraSettings.Format(from: options.format), // Ensure correct conversion here
            nightModeEnabled: options.nightModeEnabled,
            smartHDR: options.smartHDR,
            appleProRAW: options.appleProRAW,
            portraitLightingEffect: options.portraitLightingEffect,
            depthControl: options.depthControl,
            lightingIntensity: options.lightingIntensity
        )
    }
}





extension CameraSettings {
    init(from controller: CoreSettingsController) {
        self.init(
            resolution: controller.videoResolution == "1080p" ? .hd1080 : .hd4K,
            frameRate: controller.cinematicMode ? .fps24 : .fps30, // Example mapping
            format: CameraSettings.Format(rawValue: controller.format) ?? .jpeg,
            hdrEnabled: controller.hdrVideo,
            nightModeEnabled: controller.nightMode,
            cinematicModeEnabled: controller.cinematicMode,
            macroModeEnabled: controller.macroMode
        )
    }
    
    func apply(to controller: CoreSettingsController) {
        controller.videoResolution = (self.resolution == .hd1080) ? "1080p" : "4K"
        controller.cinematicMode = (self.frameRate == .fps24)
        controller.format = self.format.rawValue
        controller.hdrVideo = self.hdrEnabled
        controller.nightMode = self.nightModeEnabled
        controller.macroMode = self.macroModeEnabled
    }
}




// MARK: - AVCaptureSession Extensions

extension AVCaptureSession {
    /// Configures the session for depth data capture.
    func configureForDepthDataCapture() {
        for connection in connections where connection.inputPorts.contains(where: { $0.mediaType == .video }) {
            // No direct equivalent to `isDepthDataOutputEnabled`
            // Ensure `AVCapturePhotoOutput` is configured properly
            if let output = outputs.compactMap({ $0 as? AVCapturePhotoOutput }).first {
                output.isDepthDataDeliveryEnabled = output.isDepthDataDeliverySupported
            }
        }
    }
}

extension CameraSettings.Format {
    init(from photoFormat: PhotoFormat) {
        switch photoFormat {
        case .jpeg:
            self = .jpeg
        case .heif:
            self = .heif
        case .proRAW:
            self = .proRAW
        // Add additional cases to match all possible PhotoFormat cases
        }
    }
}
