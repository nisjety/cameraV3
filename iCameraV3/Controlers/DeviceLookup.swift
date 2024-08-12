//
//  DeviceLookup.swift
//  iCameraV3
//
//  Created by Ima Da Costa on 03/08/2024.
//

import Foundation
import AVFoundation
import Combine

final class DeviceLookup {

    // Discovery sessions to find the front, back, and external cameras, including depth sensors like LiDAR.
    private let frontCameraDiscoverySession: AVCaptureDevice.DiscoverySession
    private let backCameraDiscoverySession: AVCaptureDevice.DiscoverySession
    private let externalCameraDiscoverySession: AVCaptureDevice.DiscoverySession

    init() {
        backCameraDiscoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInDualCamera, .builtInWideAngleCamera, .builtInTelephotoCamera, .builtInLiDARDepthCamera],
            mediaType: .video,
            position: .back
        )
        frontCameraDiscoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInTrueDepthCamera, .builtInWideAngleCamera],
            mediaType: .video,
            position: .front
        )
        externalCameraDiscoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.external],
            mediaType: .video,
            position: .unspecified
        )
        
        // Set the user's preferred camera to the back camera if no system preference is defined.
        if AVCaptureDevice.systemPreferredCamera == nil {
            AVCaptureDevice.userPreferredCamera = backCameraDiscoverySession.devices.first
        }
    }
    
    var defaultCamera: AVCaptureDevice {
        get throws {
            guard let videoDevice = AVCaptureDevice.systemPreferredCamera else {
                throw CameraError.videoDeviceUnavailable
            }
            return videoDevice
        }
    }
    
    var defaultMic: AVCaptureDevice {
        get throws {
            guard let audioDevice = AVCaptureDevice.default(for: .audio) else {
                throw CameraError.audioDeviceUnavailable
            }
            return audioDevice
        }
    }
    
    var cameras: [AVCaptureDevice] {
        var cameras: [AVCaptureDevice] = []
        cameras.append(contentsOf: backCameraDiscoverySession.devices)
        cameras.append(contentsOf: frontCameraDiscoverySession.devices)
        cameras.append(contentsOf: externalCameraDiscoverySession.devices)
        
#if !targetEnvironment(simulator)
        if cameras.isEmpty {
            fatalError("No camera devices are found on this system.")
        }
#endif
        return cameras
    }
    
    func camera(at position: AVCaptureDevice.Position) throws -> AVCaptureDevice {
        let discoverySession: AVCaptureDevice.DiscoverySession
        switch position {
        case .front:
            discoverySession = frontCameraDiscoverySession
        case .back:
            discoverySession = backCameraDiscoverySession
        default:
            throw CameraError.videoDeviceUnavailable
        }
        guard let camera = discoverySession.devices.first else {
            throw CameraError.videoDeviceUnavailable
        }
        return camera
    }
    
    func capabilities(for device: AVCaptureDevice) -> [String: Any] {
        var capabilities: [String: Any] = [:]
        capabilities["Max Zoom Factor"] = device.activeFormat.videoMaxZoomFactor
        capabilities["Low Light Boost Supported"] = device.isLowLightBoostSupported
        capabilities["Video Stabilization Modes"] = device.activeFormat.videoSupportedFrameRateRanges.map { $0.minFrameRate } // Updated to reflect frame rates.
        capabilities["HDR Supported"] = device.activeFormat.isVideoHDRSupported
        capabilities["Depth Data Capture Supported"] = !device.activeFormat.supportedDepthDataFormats.isEmpty // Updated for depth data support.
        return capabilities
    }

    func isProRAWSupported(for device: AVCaptureDevice) -> Bool {
        return device.isProRAWSupported
    }

    func isProResSupported(for device: AVCaptureDevice) -> Bool {
        return device.activeFormat.isVideoStabilizationModeSupported(.cinematic)
    }

    func isMultiCameraSupported() -> Bool {
        return AVCaptureMultiCamSession.isMultiCamSupported
    }

    func isCinematicModeSupported(for device: AVCaptureDevice) -> Bool {
        return device.activeFormat.isVideoStabilizationModeSupported(.cinematic)
    }

    // Macro mode support would need to be handled by specific checks or configurations, not a direct property.
    func isMacroModeSupported(for device: AVCaptureDevice) -> Bool {
        // Implement logic based on the device's capabilities, e.g., checking for a specific minimum focus distance
        return false
    }
}
