//
//  CaptureService.swift
//  iCameraV3
//
//  Created by Ima Da Costa on 03/08/2024.
//

import Foundation
import AVFoundation
import Combine
import CoreML
import Vision
import CoreLocation
import os

// MARK: - Definitions

struct AIToggleSettings {
    var faceDetectionEnabled: Bool
    var objectDetectionEnabled: Bool
    var imageAlignmentEnabled: Bool
    var textRecognitionEnabled: Bool
    var imageClassificationEnabled: Bool
    var adobeSenseiEnabled: Bool
    var gptEnabled: Bool
}

// Placeholder for YOLOv3 (replace with your actual CoreML model)
// class YOLOv3 {
//     var model: MLModel {
//         return try! MLModel(contentsOf: URL(fileURLWithPath: "path/to/your/model"))
//     }
// }


let logger = Logger(subsystem: "com.yourapp.icamera", category: "CaptureService")

actor CaptureService: ObservableObject {
    @Published private(set) var captureActivity: CaptureActivity = .idle
    @Published private(set) var captureCapabilities = CaptureCapabilities.unknown
    @Published private(set) var isInterrupted = false
    @Published var isHDRVideoEnabled = false

    private let captureSession = AVCaptureSession()
    private let photoCapture: PhotoCapture
    private let movieCapture: MovieCapture
    private var outputServices: [any OutputService] { [photoCapture, movieCapture] }
    private var activeVideoInput: AVCaptureDeviceInput?
    private(set) var captureMode = CaptureMode.photo
    private let deviceLookup = DeviceLookup()
    private let systemPreferredCamera = SystemPreferredCameraObserver()
    private var rotationCoordinator: AVCaptureDevice.RotationCoordinator?
    private var rotationObservers = [AnyObject]()
    private var isSetUp = false

    private var faceDetectionRequest: VNRequest?
    // private var objectDetectionRequest: VNRequest?

    private var aiToggleSettings = AIToggleSettings(
        faceDetectionEnabled: true,
        objectDetectionEnabled: true,
        imageAlignmentEnabled: false,
        textRecognitionEnabled: false,
        imageClassificationEnabled: true,
        adobeSenseiEnabled: true,
        gptEnabled: true
    )

    init(model: MLModel? = nil) {
        self.photoCapture = PhotoCapture()
        self.movieCapture = MovieCapture(model: model)

        Task {
            await configureFaceDetection()
            // await configureObjectDetection()
        }
    }

    // MARK: - Authorization
    var isAuthorized: Bool {
        get async {
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            var isAuthorized = status == .authorized
            if status == .notDetermined {
                isAuthorized = await AVCaptureDevice.requestAccess(for: .video)
            }
            return isAuthorized
        }
    }

    // MARK: - Session Management
    func start() async throws {
        guard await isAuthorized, !captureSession.isRunning else { return }
        try await setUpSession()
        captureSession.startRunning()
    }

    private func setUpSession() async throws {
        guard !isSetUp else { return }

        observeOutputServices()
        observeNotifications()

        do {
            let defaultCamera = try deviceLookup.defaultCamera
            let defaultMic = try deviceLookup.defaultMic

            activeVideoInput = try addInput(for: defaultCamera)
            try addInput(for: defaultMic)

            captureSession.sessionPreset = .photo
            try await addOutput(photoCapture.output)

            monitorSystemPreferredCamera()
            createRotationCoordinator(for: defaultCamera)
            observeSubjectAreaChanges(of: defaultCamera)
            updateCaptureCapabilities()

            isSetUp = true
        } catch {
            throw CameraError.setupFailed
        }
    }
    
    /// Computed property to get the current camera position.
        var currentCameraPosition: AVCaptureDevice.Position? {
            guard let activeInput = activeVideoInput else {
                return nil
            }
            return activeInput.device.position
        }

    @discardableResult
    private func addInput(for device: AVCaptureDevice) throws -> AVCaptureDeviceInput {
        let input = try AVCaptureDeviceInput(device: device)
        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        } else {
            throw CameraError.addInputFailed
        }
        return input
    }

    private func addOutput(_ output: AVCaptureOutput) async throws {
        if captureSession.canAddOutput(output) {
            captureSession.addOutput(output)
        } else {
            throw CameraError.addOutputFailed
        }
    }

    private var currentDevice: AVCaptureDevice {
        guard let device = activeVideoInput?.device else {
            fatalError("No device found for current video input.")
        }
        return device
    }

    // MARK: - Capture Mode Management
    func setCaptureMode(_ captureMode: CaptureMode) async throws {
        self.captureMode = captureMode

        captureSession.beginConfiguration()
        defer { captureSession.commitConfiguration() }

        switch captureMode {
        case .photo:
            captureSession.sessionPreset = .photo
            captureSession.removeOutput(movieCapture.output)
        case .video:
            captureSession.sessionPreset = .high
            try await addOutput(movieCapture.output)
            if isHDRVideoEnabled {
                await setHDRVideoEnabled(true)
            }
        }

        updateCaptureCapabilities()
    }

    // MARK: - Device Management
    func selectNextVideoDevice() {
        let videoDevices = deviceLookup.cameras
        let selectedIndex = videoDevices.firstIndex(of: currentDevice) ?? 0
        var nextIndex = selectedIndex + 1
        if nextIndex == videoDevices.endIndex {
            nextIndex = 0
        }
        
        let nextDevice = videoDevices[nextIndex]
        changeCaptureDevice(to: nextDevice)
        AVCaptureDevice.userPreferredCamera = nextDevice
    }

    private func changeCaptureDevice(to device: AVCaptureDevice) {
        guard let currentInput = activeVideoInput else { fatalError() }
        
        captureSession.beginConfiguration()
        defer { captureSession.commitConfiguration() }
        
        captureSession.removeInput(currentInput)
        do {
            activeVideoInput = try addInput(for: device)
            createRotationCoordinator(for: device)
            observeSubjectAreaChanges(of: device)
            updateCaptureCapabilities()
        } catch {
            captureSession.addInput(currentInput)
        }
    }
    
    private func monitorSystemPreferredCamera() {
        Task {
            for await camera in systemPreferredCamera.changes {
                if let camera, currentDevice != camera {
                    logger.debug("Switching camera selection to the system-preferred camera.")
                    changeCaptureDevice(to: camera)
                }
            }
        }
    }

    // MARK: - Advanced Capture Features

    func setHDRVideoEnabled(_ enabled: Bool) async {
        captureSession.beginConfiguration()
        defer { captureSession.commitConfiguration() }
        do {
            if enabled, let format = currentDevice.activeFormat10BitVariant {
                try currentDevice.lockForConfiguration()
                currentDevice.activeFormat = format
                currentDevice.unlockForConfiguration()
                isHDRVideoEnabled = true
            } else {
                captureSession.sessionPreset = .high
                isHDRVideoEnabled = false
            }
        } catch {
            logger.error("Unable to obtain lock on device and can't enable HDR video capture.")
        }
    }

    private func configureFaceDetection() async {
        let faceDetectionRequest = VNDetectFaceRectanglesRequest(completionHandler: { request, error in
            if let results = request.results as? [VNFaceObservation] {
                Task {
                    await self.handleFaceDetection(results: results)
                }
            }
        })
        self.faceDetectionRequest = faceDetectionRequest
    }

    private func handleFaceDetection(results: [VNFaceObservation]) async {
        guard let currentDevice = activeVideoInput?.device else { return }
        do {
            try currentDevice.lockForConfiguration()
            for face in results {
                let boundingBox = face.boundingBox
                let focusPoint = CGPoint(x: boundingBox.midX, y: boundingBox.midY)
                currentDevice.focusPointOfInterest = focusPoint
                currentDevice.focusMode = .continuousAutoFocus
                let zoomFactor = max(1.0, min(5.0, 1.0 / boundingBox.width))
                currentDevice.videoZoomFactor = zoomFactor
            }
            currentDevice.unlockForConfiguration()
        } catch {
            logger.error("Failed to adjust camera settings: \(error)")
        }
    }

    // MARK: - AI and ML Enhancements
    // Commented out to implement later
    /*
    private func configureObjectDetection() async {
        guard aiToggleSettings.objectDetectionEnabled,
              let model = try? VNCoreMLModel(for: YOLOv3().model) else { return }
        
        let objectDetectionRequest = VNCoreMLRequest(model: model, completionHandler: { request, error in
            if let results = request.results as? [VNRecognizedObjectObservation] {
                Task {
                    await self.handleObjectDetection(results: results)
                }
            }
        })
        self.objectDetectionRequest = objectDetectionRequest
    }

    private func handleObjectDetection(results: [VNRecognizedObjectObservation]) async {
        for object in results {
            logger.debug("Detected object: \(object.labels.first?.identifier ?? "Unknown") with confidence \(object.confidence)")
        }
    }
    */

    // MARK: - Multi-Camera Setup
    func configureMultiCameraCapture() async {
        guard AVCaptureMultiCamSession.isMultiCamSupported else {
            logger.error("Multi-Camera capture is not supported on this device.")
            return
        }

        let multiCamSession = AVCaptureMultiCamSession()

        do {
            let primaryCamera = try deviceLookup.camera(at: .back)
            let primaryCameraInput = try AVCaptureDeviceInput(device: primaryCamera)
            guard multiCamSession.canAddInput(primaryCameraInput) else { return }
            multiCamSession.addInput(primaryCameraInput)

            let secondaryCamera = try deviceLookup.camera(at: .front)
            let secondaryCameraInput = try AVCaptureDeviceInput(device: secondaryCamera)
            guard multiCamSession.canAddInput(secondaryCameraInput) else { return }
            multiCamSession.addInput(secondaryCameraInput)

            let primaryOutput = AVCaptureMovieFileOutput()
            guard multiCamSession.canAddOutput(primaryOutput) else { return }
            multiCamSession.addOutput(primaryOutput)

            let secondaryOutput = AVCaptureMovieFileOutput()
            guard multiCamSession.canAddOutput(secondaryOutput) else { return }
            multiCamSession.addOutput(secondaryOutput)

            multiCamSession.startRunning()
            // Handle session replacement properly
            // You can't replace a `let` constant, so manage sessions differently if needed
            // Use a `var` or consider session management through a dedicated class or struct.
        } catch {
            logger.error("Failed to configure multi-camera capture: \(error)")
        }
    }

    // MARK: - Automatic focus and exposure
    
    /// Performs a one-time automatic focus and expose operation.
    ///
    /// The app calls this method as the result of a person tapping on the preview area.
    func focusAndExpose(at point: CGPoint) {
        // The point this call receives is in view-space coordinates. Convert this point to device coordinates.
        let devicePoint = videoPreviewLayer.captureDevicePointConverted(fromLayerPoint: point)
        do {
            // Perform a user-initiated focus and expose.
            try focusAndExpose(at: devicePoint, isUserInitiated: true)
        } catch {
            logger.debug("Unable to perform focus and exposure operation. \(error)")
        }
    }
    
    private var subjectAreaChangeTask: Task<Void, Never>?
    
    private func focusAndExpose(at devicePoint: CGPoint, isUserInitiated: Bool) throws {
        let device = currentDevice
        
        try device.lockForConfiguration()
        
        let focusMode = isUserInitiated ? AVCaptureDevice.FocusMode.autoFocus : .continuousAutoFocus
        if device.isFocusPointOfInterestSupported && device.isFocusModeSupported(focusMode) {
            device.focusPointOfInterest = devicePoint
            device.focusMode = focusMode
        }
        let exposureMode = isUserInitiated ? AVCaptureDevice.ExposureMode.autoExpose : .continuousAutoExposure
        if device.isExposurePointOfInterestSupported && device.isExposureModeSupported(exposureMode) {
            device.exposurePointOfInterest = devicePoint
            device.exposureMode = exposureMode
        }
        device.isSubjectAreaChangeMonitoringEnabled = isUserInitiated
        device.unlockForConfiguration()
    }

    // MARK: - Photo and Video Capture
    func capturePhoto(with features: EnabledPhotoFeatures, settings: CoreSettingsController) async throws -> Photo {
        let photoSettings = createPhotoSettings(from: features)
        return try await photoCapture.capturePhoto(with: features, settings: settings)
    }


    func startRecording() {
        movieCapture.startRecording()
    }
    
    func stopRecording() async throws -> Movie {
        try await movieCapture.stopRecording()
    }
    
    func createPhotoSettings(from features: EnabledPhotoFeatures) -> AVCapturePhotoSettings {
        var settings: AVCapturePhotoSettings

        if features.format == .proRAW {
            settings = AVCapturePhotoSettings(rawPixelFormatType: kCVPixelFormatType_14Bayer_RGGB)
        } else {
            settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
        }

        // Configure settings based on features
        settings.flashMode = features.flashMode
        
        // Set the maximum photo dimensions
        settings.maxPhotoDimensions = CMVideoDimensions(width: 4032, height: 3024) // Example dimensions
        
        settings.isDepthDataDeliveryEnabled = features.depthEnabled
        
        return settings
    }




    // MARK: - Internal state management
    private func updateCaptureCapabilities() {
        outputServices.forEach { $0.updateConfiguration(for: currentDevice) }
        switch captureMode {
        case .photo:
            captureCapabilities = photoCapture.capabilities
        case .video:
            captureCapabilities = movieCapture.capabilities
        }
    }

    private func observeOutputServices() {
        Publishers.Merge(photoCapture.$captureActivity, movieCapture.$captureActivity)
            .assign(to: &$captureActivity)
    }

    private func observeNotifications() {
        Task {
            for await reason in NotificationCenter.default.notifications(named: NSNotification.Name.AVCaptureSessionWasInterrupted)
                .compactMap({ $0.userInfo?[AVCaptureSessionInterruptionReasonKey] as AnyObject? })
                .compactMap({ AVCaptureSession.InterruptionReason(rawValue: $0.integerValue) }) {
                isInterrupted = [.audioDeviceInUseByAnotherClient, .videoDeviceInUseByAnotherClient].contains(reason)
            }
        }
        
        Task {
                for await _ in NotificationCenter.default.notifications(named: .AVCaptureSessionInterruptionEnded) {
                    isInterrupted = false
                }
            }
        
        Task {
            for await error in NotificationCenter.default.notifications(named: NSNotification.Name.AVCaptureSessionRuntimeError)
                .compactMap({ $0.userInfo?[AVCaptureSessionErrorKey] as? AVError }) {
                if error.code == .mediaServicesWereReset {
                    if !captureSession.isRunning {
                        captureSession.startRunning()
                    }
                }
            }
        }
    }

    // MARK: - Rotation and Orientation Handling
    private func createRotationCoordinator(for device: AVCaptureDevice) {
        rotationCoordinator = AVCaptureDevice.RotationCoordinator(device: device, previewLayer: videoPreviewLayer)
        updatePreviewRotation(rotationCoordinator!.videoRotationAngleForHorizonLevelPreview)
        updateCaptureRotation(rotationCoordinator!.videoRotationAngleForHorizonLevelCapture)
        rotationObservers.removeAll()
        rotationObservers.append(
            rotationCoordinator!.observe(\.videoRotationAngleForHorizonLevelPreview, options: .new) { [weak self] _, change in
                guard let self, let angle = change.newValue else { return }
                Task { await self.updatePreviewRotation(angle) }
            }
        )
        rotationObservers.append(
            rotationCoordinator!.observe(\.videoRotationAngleForHorizonLevelCapture, options: .new) { [weak self] _, change in
                guard let self, let angle = change.newValue else { return }
                Task { await self.updateCaptureRotation(angle) }
            }
        )
    }

    private func updatePreviewRotation(_ angle: CGFloat) {
        let previewLayer = videoPreviewLayer
        Task { @MainActor in
            previewLayer.connection?.videoRotationAngle = angle
        }
    }

    private func updateCaptureRotation(_ angle: CGFloat) {
        outputServices.forEach { $0.setVideoRotationAngle(angle) }
    }

    private var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        guard let previewLayer = captureSession.connections.compactMap({ $0.videoPreviewLayer }).first else {
            fatalError("The app is misconfigured. The capture session should have a connection to a preview layer.")
        }
        return previewLayer
    }
    
    // missing
    func detectReadiness() async -> Bool {
        // Implement the logic to detect camera readiness
        return true
    }

    func setManualFocus(to point: CGPoint) async {
        // Implement manual focus logic
    }

    func setManualExposure(to value: Float) async {
        // Implement manual exposure logic
    }

    func setManualWhiteBalance(to value: Float) async {
        // Implement manual white balance logic
    }

    func configureDepthDataOutput() async {
        // Configure depth data output
    }

    /*
    func runTensorFlowLiteModel(onFrame frame: UIImage) async -> [Float]? {
        // Implement TensorFlow Lite model inference
        return nil
    }

    func integrateARKitFeatures() async {
        // Integrate ARKit features if needed
    }
*/

    private func observeSubjectAreaChanges(of device: AVCaptureDevice) {
        subjectAreaChangeTask?.cancel()
        subjectAreaChangeTask = Task {
            for await _ in NotificationCenter.default.notifications(named: NSNotification.Name.AVCaptureDeviceSubjectAreaDidChange, object: device).compactMap({ _ in true }) {
                try? focusAndExpose(at: CGPoint(x: 0.5, y: 0.5), isUserInitiated: false)
            }
        }
    }
}
