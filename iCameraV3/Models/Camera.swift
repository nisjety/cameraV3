//
//  Camera.swift
//  iCameraV3
//
//  Created by Ima Da Costa on 25/07/2024.
//

import SwiftUI
import CoreML
import Vision
import AVFoundation
import ARKit

@MainActor
protocol Camera: AnyObject {
    var status: CameraStatus { get }
    var captureActivity: CaptureActivity { get }
    var previewSource: PreviewSource { get }
    var captureMode: CaptureMode { get set }
    var isSwitchingModes: Bool { get }
    var isSwitchingVideoDevices: Bool { get }
    var photoFeatures: PhotoFeatures { get }
    var shouldFlashScreen: Bool { get }
    var isHDRVideoSupported: Bool { get }
    var isHDRVideoEnabled: Bool { get set }
    var thumbnail: CGImage? { get }
    var error: Error? { get }
    var isAIReadinessDetectionEnabled: Bool { get set }
    var manualControls: ManualControls { get set }
    var photoSaveOptions: PhotoSaveOptions { get set }
    var isFaceAutoFocusEnabled: Bool { get set }
    var isFaceAutoExposureEnabled: Bool { get set }
    var depthDataOutput: AVCaptureDepthDataOutput? { get set }

    func start() async
    func switchVideoDevices() async
    func focusAndExpose(at point: CGPoint) async
    func capturePhoto(options: PhotoSaveOptions) async
    func toggleRecording() async
    func detectReadiness() async -> Bool
    func setManualFocus(to point: CGPoint) async
    func setManualExposure(to value: Float) async
    func setManualWhiteBalance(to value: Float) async
    func configureDepthDataOutput() async
    func runTensorFlowLiteModel(onFrame frame: UIImage) async -> [Float]?
    func integrateARKitFeatures() async
}
