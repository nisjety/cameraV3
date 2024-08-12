//
//  MovieCapture.swift
//  iCameraV3
//
//  Created by Ima Da Costa on 03/08/2024.
//

import Foundation
import AVFoundation
import CoreML
import Vision
import Combine

final class MovieCapture: OutputService {
    
    @Published private(set) var captureActivity: CaptureActivity = .idle
    let output = AVCaptureMovieFileOutput()
    private var movieOutput: AVCaptureMovieFileOutput { output }
    private var delegate: MovieCaptureDelegate?
    private var timerCancellable: AnyCancellable?
    private var isHDRSupported = false
    
    private var videoProcessingModel: VNCoreMLModel?
    private let sessionQueue = DispatchQueue(label: "MovieCapture.SessionQueue")

    // Required to conform to OutputService
    var capabilities: CaptureCapabilities {
        // Implement the logic to return the correct capabilities.
        return CaptureCapabilities(
            isFlashSupported: false, // Movie mode typically doesn't use flash.
            isLivePhotoCaptureSupported: false, // Movie mode doesn't support Live Photos.
            isHDRSupported: isHDRSupported
        )
    }

    init(model: MLModel?) {
        if let model = model {
            self.videoProcessingModel = try? VNCoreMLModel(for: model)
        }
    }
    
    // MARK: - Core Recording Functionality
    
    func startRecording() {
        guard !movieOutput.isRecording else { return }
        guard let connection = movieOutput.connection(with: .video) else {
            fatalError("Configuration error: No video connection.")
        }
        
        configureConnection(connection)
        startMonitoringDuration()
        
        delegate = MovieCaptureDelegate()
        movieOutput.startRecording(to: createOutputURL(), recordingDelegate: delegate!)
    }
    
    func stopRecording() async throws -> Movie {
        return try await withCheckedThrowingContinuation { continuation in
            delegate?.continuation = continuation
            movieOutput.stopRecording()
            stopMonitoringDuration()
        }
    }
    
    private func configureConnection(_ connection: AVCaptureConnection) {
        if movieOutput.availableVideoCodecTypes.contains(.hevc) {
            movieOutput.setOutputSettings([AVVideoCodecKey: AVVideoCodecType.hevc], for: connection)
        }
        
        if connection.isVideoStabilizationSupported {
            connection.preferredVideoStabilizationMode = .auto
        }
        
        // Access the device by casting the input to AVCaptureDeviceInput
        if let deviceInput = connection.inputPorts.first?.input as? AVCaptureDeviceInput {
            let device = deviceInput.device
            if device.activeFormat.isVideoHDRSupported {
                isHDRSupported = true
            }
        }
        
        if movieOutput.availableVideoCodecTypes.contains(.proRes422) {
            movieOutput.setOutputSettings([AVVideoCodecKey: AVVideoCodecType.proRes422], for: connection)
        }
    }

    
    // MARK: - Monitoring and UI Interaction
    
    private func startMonitoringDuration() {
        captureActivity = .movieCapture()
        timerCancellable = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                let duration = self.movieOutput.recordedDuration.seconds
                self.captureActivity = .movieCapture(duration: duration)
            }
    }
    
    private func stopMonitoringDuration() {
        timerCancellable?.cancel()
        captureActivity = .idle
    }
    
    // MARK: - Error Handling and Robustness
    
    func updateConfiguration(for device: AVCaptureDevice) {
        isHDRSupported = device.activeFormat.isVideoHDRSupported
    }
    
    // MARK: - Output Management
    
    private func createOutputURL() -> URL {
        let fileManager = FileManager.default
        let directory = fileManager.temporaryDirectory
        let uuid = UUID().uuidString
        return directory.appendingPathComponent("\(uuid).mov")
    }
    
    // MARK: - Delegate and Movie creation
    
    private class MovieCaptureDelegate: NSObject, AVCaptureFileOutputRecordingDelegate {
        
        var continuation: CheckedContinuation<Movie, Error>?
        
        func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
            if let error = error {
                continuation?.resume(throwing: error)
            } else {
                continuation?.resume(returning: Movie(url: outputFileURL))
            }
        }
    }
    
    // MARK: - Real-Time Video Processing
    
    private func applyRealTimeProcessing(to sampleBuffer: CMSampleBuffer) {
        guard let model = videoProcessingModel else { return }
        
        let request = VNCoreMLRequest(model: model) { request, error in
            if let error = error {
                print("Error during CoreML request: \(error)")
                return
            }
            
            // Process the specific observation results here if needed
            if let results = request.results as? [VNClassificationObservation] {
                // Handle classification results
            } else if let results = request.results as? [VNFaceObservation] {
                // Handle face detection results
            }
        }
        
        let handler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer, options: [:])
        do {
            try handler.perform([request])
        } catch {
            print("Error performing image request: \(error)")
        }
    }

    
    // MARK: - Dynamic Configuration Updates
    
    func setZoom(level: CGFloat) {
        sessionQueue.async {
            if let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
                do {
                    try videoDevice.lockForConfiguration()
                    videoDevice.videoZoomFactor = max(1.0, min(level, videoDevice.activeFormat.videoMaxZoomFactor))
                    videoDevice.unlockForConfiguration()
                } catch {
                    print("Error setting zoom level: \(error)")
                }
            }
        }
    }

    func startRecordingWithDelay(delay: TimeInterval) {
        guard !movieOutput.isRecording else { return }
        guard let connection = movieOutput.connection(with: .video) else {
            fatalError("Configuration error: No video connection.")
        }

        configureConnection(connection)

        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            self.delegate = MovieCaptureDelegate()
            self.movieOutput.startRecording(to: self.createOutputURL(), recordingDelegate: self.delegate!)
        }
    }
}
