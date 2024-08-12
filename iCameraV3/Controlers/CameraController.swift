//
//  CameraController.swift
//  iCameraV3
//
//  Created by Ima Da Costa on 07/08/2024.
//

import Foundation
import AVFoundation
import CoreImage
import Vision
import SwiftUI
import Photos

enum CameraResolution: String, CaseIterable, Identifiable {
    case fourK = "4K"
    case fullHD = "1080p"
    case hd = "720p"

    var id: String { self.rawValue }
}

class CameraController: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate, AVCapturePhotoCaptureDelegate {
    @Published var frame: CGImage?
    @Published var zoomLevel: CGFloat = 1.0
    @Published var flashMode: AVCaptureDevice.FlashMode = .auto
    @Published var hdrEnabled: Bool = false {
        didSet {
            updateHDR()
        }
    }
    @Published var resolution: CameraResolution = .fourK {
        didSet {
            updateSessionPreset()
        }
    }
    @Published var capturedPhoto: UIImage?
    private(set) var captureSession = AVCaptureSession()
    private var permissionGranted = false
    private let sessionQueue = DispatchQueue(label: "sessionQueue")
    private let context = CIContext()
    private var currentDevice: AVCaptureDevice?
    private let photoOutput = AVCapturePhotoOutput()

    override init() {
        super.init()
        self.checkPermission()
    }

    // Check camera permission
    func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            self.permissionGranted = true
            setupCaptureSession()
        case .notDetermined:
            requestPermission()
        default:
            self.permissionGranted = false
        }
    }

    // Request camera permission
    func requestPermission() {
        AVCaptureDevice.requestAccess(for: .video) { [unowned self] granted in
            self.permissionGranted = granted
            if granted {
                self.sessionQueue.async {
                    self.setupCaptureSession()
                }
            }
        }
    }

    // Setup capture session
    func setupCaptureSession() {
        guard permissionGranted else { return }

        sessionQueue.async {
            let videoOutput = AVCaptureVideoDataOutput()
            guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else { return }
            self.currentDevice = videoDevice
            guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice) else { return }
            
            self.captureSession.beginConfiguration()
            
            if self.captureSession.canAddInput(videoDeviceInput) {
                self.captureSession.addInput(videoDeviceInput)
            }
            
            videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sampleBufferQueue"))
            if self.captureSession.canAddOutput(videoOutput) {
                self.captureSession.addOutput(videoOutput)
            }

            if self.captureSession.canAddOutput(self.photoOutput) {
                self.captureSession.addOutput(self.photoOutput)
            }
            
            self.updateSessionPreset()
            self.updateHDR()
            
            if let videoConnection = videoOutput.connection(with: .video) {
                videoConnection.videoRotationAngle = 0 // Or set it to a specific angle if needed
            }
            
            self.captureSession.commitConfiguration()
            
            self.startSession()
        }
    }


    // Start capture session
    func startSession() {
        if !captureSession.isRunning {
            sessionQueue.async {
                self.captureSession.startRunning()
            }
        }
    }

    // Switch between front and back camera
    func switchCamera() {
        guard let currentDevice = currentDevice else { return }
        
        sessionQueue.async {
            self.captureSession.beginConfiguration()
            
            let newPosition: AVCaptureDevice.Position = (currentDevice.position == .back) ? .front : .back
            self.captureSession.inputs.forEach { self.captureSession.removeInput($0) }
            
            guard let newDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: newPosition),
                  let newInput = try? AVCaptureDeviceInput(device: newDevice) else { return }
            
            if self.captureSession.canAddInput(newInput) {
                self.captureSession.addInput(newInput)
                self.currentDevice = newDevice
            }
            
            self.captureSession.commitConfiguration()
            
            self.startSession()
        }
    }

    // Toggle flash mode
    func toggleFlash() {
        guard let device = currentDevice, device.hasTorch else { return }
        try? device.lockForConfiguration()
        device.torchMode = device.torchMode == .on ? .off : .on
        device.unlockForConfiguration()
    }

    // Zoom control method (to be connected to a slider)
    func setZoomFactor(_ zoomFactor: CGFloat) {
        guard let device = currentDevice else { return }
        do {
            try device.lockForConfiguration()
            device.videoZoomFactor = max(1.0, min(zoomFactor, device.activeFormat.videoMaxZoomFactor))
            device.unlockForConfiguration()
        } catch {
            print("Error setting zoom factor: \(error)")
        }
    }

    // Update session preset
    func updateSessionPreset() {
        sessionQueue.async {
            self.captureSession.beginConfiguration()
            switch self.resolution {
            case .fourK:
                self.captureSession.sessionPreset = .hd4K3840x2160
            case .fullHD:
                self.captureSession.sessionPreset = .high
            case .hd:
                self.captureSession.sessionPreset = .medium
            }
            self.captureSession.commitConfiguration()
        }
    }

    // Update HDR setting
    func updateHDR() {
        guard let device = currentDevice else { return }
        do {
            try device.lockForConfiguration()
            device.automaticallyAdjustsVideoHDREnabled = false
            device.isVideoHDREnabled = hdrEnabled
            device.unlockForConfiguration()
        } catch {
            print("Error setting HDR: \(error)")
        }
    }

    // Apply Core Image filters to the captured image
    private func applyFilters(to image: UIImage) -> UIImage? {
        guard let ciImage = CIImage(image: image) else { return nil }
        
        let filter = CIFilter(name: "CIColorControls")!
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(0.1, forKey: kCIInputBrightnessKey) // Adjust brightness
        filter.setValue(1.5, forKey: kCIInputContrastKey)    // Adjust contrast
        
        guard let outputImage = filter.outputImage,
              let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage)
    }

    // Save the processed photo to the photo library
    private func savePhoto(_ image: UIImage) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }) { success, error in
            if success {
                print("Photo saved successfully")
            } else if let error = error {
                print("Error saving photo: \(error)")
            }
        }
    }

    // Capture photo and apply filters
    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        settings.flashMode = flashMode
        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    // Handle captured photo
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation(), let image = UIImage(data: imageData) else {
            return
        }
        
        let enhancedImage = applyFilters(to: image)
        capturedPhoto = enhancedImage
        
        if let finalImage = enhancedImage {
            savePhoto(finalImage)
        }
    }

    // Vision framework integration for face detection
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let handler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer, options: [:])
        let request = VNDetectFaceRectanglesRequest { (request, error) in
            if let results = request.results as? [VNFaceObservation] {
                self.handleDetectedFaces(results)
            }
        }
        try? handler.perform([request])
    }

    private func handleDetectedFaces(_ faces: [VNFaceObservation]) {
        // Handle the detected face observations here
        for face in faces {
            print("Detected face at \(face.boundingBox)")
        }
    }

    private var latestBuffer: CMSampleBuffer?

    private func imageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> CGImage? {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        return context.createCGImage(ciImage, from: ciImage.extent)
    }

    // Toggle Auto Focus
    func toggleAutoFocus() {
        // Implement auto focus toggle logic
        print("Auto Focus toggled")
    }

    // Toggle Zoom
    func toggleZoom() {
        // Implement zoom toggle logic
        print("Zoom toggled")
    }

    // Focus at a specific point
    func focus(at point: CGPoint) {
        guard let device = currentDevice else { return }
        do {
            try device.lockForConfiguration()
            if device.isFocusPointOfInterestSupported {
                device.focusPointOfInterest = point
                device.focusMode = .autoFocus
            }
            if device.isExposurePointOfInterestSupported {
                device.exposurePointOfInterest = point
                device.exposureMode = .continuousAutoExposure
            }
            device.unlockForConfiguration()
        } catch {
            print("Error focusing at point: \(error)")
        }
    }
}
