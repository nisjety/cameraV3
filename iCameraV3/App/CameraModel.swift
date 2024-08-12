//
//  CameraModel.swift
//  iCameraV3
//
//  Created by Ima Da Costa on 03/08/2024.
//

import AVFoundation
import SwiftUI
import CoreML
import Vision
import ARKit

@MainActor
final class CameraModel: ObservableObject, Camera {
    
    @Published private(set) var status: CameraStatus = .unknown
    @Published private(set) var captureActivity: CaptureActivity = .idle
    @Published private(set) var previewSource: PreviewSource = DefaultPreviewSource(session: AVCaptureSession())
    @Published var captureMode: CaptureMode = .photo
    @Published private(set) var isSwitchingModes: Bool = false
    @Published private(set) var isSwitchingVideoDevices: Bool = false
    @Published private(set) var shouldFlashScreen: Bool = false
    @Published private(set) var isHDRVideoSupported: Bool = false
    @Published var isHDRVideoEnabled: Bool = false
    @Published var currentCameraPosition: AVCaptureDevice.Position = .back
    @Published private(set) var thumbnail: CGImage? = nil
    @Published private(set) var error: Error? = nil
    @Published var isAIReadinessDetectionEnabled: Bool = false
    @Published var manualControls: ManualControls = ManualControls()
    @Published var photoSaveOptions: PhotoSaveOptions = PhotoSaveOptions(
        flashMode: .auto,
        hdrMode: true,
        photoQuality: 85,
        aspectRatio: .fourByThree,
        exposureValue: 0.0,
        timer: .off,
        selectedFilter: .none,
        macroMode: false,
        depthEnabled: false,
        livePhotosMode: false,
        format: .jpeg, // Ensure you include this line
        nightModeEnabled: false,
        smartHDR: false,
        appleProRAW: false,
        portraitLightingEffect: "Natural Light",
        depthControl: 0.0,
        lightingIntensity: 0.0,
        isFlashEnabled: false, // Add this argument
        isLivePhotoEnabled: false, // Add this argument
        qualityPrioritization: .quality // Add this argument
    )

    @Published var isFaceAutoFocusEnabled: Bool = false
    @Published var isFaceAutoExposureEnabled: Bool = false
    @Published var depthDataOutput: AVCaptureDepthDataOutput? = nil
    @Published private(set) var photoFeatures: PhotoFeatures = PhotoFeatures()
    
    private let mediaLibrary = MediaLibrary()
    private let captureService = CaptureService()

    init() {
    }

    func start() async {
        guard await captureService.isAuthorized else {
            status = .unauthorized
            return
        }
        do {
            try await captureService.start()
            observeState()
            status = .running
        } catch {
            status = .failed(error)
        }
    }

    func switchVideoDevices() async {
        isSwitchingVideoDevices = true
        defer { isSwitchingVideoDevices = false }
        await captureService.selectNextVideoDevice()
    }

    func focusAndExpose(at point: CGPoint) async {
        await captureService.focusAndExpose(at: point)
    }

    func capturePhoto(options: PhotoSaveOptions) async {
        do {
            let features = EnabledPhotoFeatures(from: options)
            let photo = try await captureService.capturePhoto(with: features)
            try await mediaLibrary.save(photo: photo)
        } catch {
            self.error = error
        }
    }
    
    var isFrontMode: Bool {
        return currentCameraPosition == .front
    }


    func toggleRecording() async {
        switch await captureService.captureActivity {
        case .movieCapture:
            do {
                let movie = try await captureService.stopRecording()
                try await mediaLibrary.save(movie: movie)
            } catch {
                self.error = error
            }
        default:
            await captureService.startRecording()
        }
    }

    func detectReadiness() async -> Bool {
        return await captureService.detectReadiness()
    }

    func setManualFocus(to point: CGPoint) async {
        await captureService.setManualFocus(to: point)
    }

    func setManualExposure(to value: Float) async {
        await captureService.setManualExposure(to: value)
    }

    func setManualWhiteBalance(to value: Float) async {
        await captureService.setManualWhiteBalance(to: value)
    }

    func configureDepthDataOutput() async {
        await captureService.configureDepthDataOutput()
    }

    func runTensorFlowLiteModel(onFrame frame: UIImage) async -> [Float]? {
        // Placeholder for the TensorFlow Lite model inference
        return nil
    }

    func integrateARKitFeatures() async {
        // Placeholder for ARKit feature integration
    }
    
    private func observeState() {
        Task {
            for await thumbnail in mediaLibrary.thumbnails.compactMap({ $0 }) {
                self.thumbnail = thumbnail
            }
        }
        
        Task {
            for await activity in await captureService.$captureActivity.values {
                if activity.willCapture {
                    flashScreen()
                } else {
                    captureActivity = activity
                }
            }
        }
        
        Task {
            for await capabilities in await captureService.$captureCapabilities.values {
                isHDRVideoSupported = capabilities.isHDRSupported
            }
        }
    }
    
    

    private func flashScreen() {
        shouldFlashScreen = true
        withAnimation(.linear(duration: 0.01)) {
            shouldFlashScreen = false
        }
    }
}
