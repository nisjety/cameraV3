import Foundation
import AVFoundation
import CoreImage


final class PhotoCapture: OutputService {
    
    @Published private(set) var captureActivity: CaptureActivity = .idle
    
    let output = AVCapturePhotoOutput()
    
    private var photoOutput: AVCapturePhotoOutput { output }
    
    private(set) var capabilities: CaptureCapabilities = .unknown
    
    private var livePhotoCount = 0
    
    // MARK: - Capture a photo.
    
    func capturePhoto(with features: EnabledPhotoFeatures, settings: CoreSettingsController) async throws -> Photo {
        try await withCheckedThrowingContinuation { continuation in
            
            let photoSettings = createPhotoSettings(with: features, settings: settings)
            
            let delegate = PhotoCaptureDelegate(continuation: continuation, features: features)
            monitorProgress(of: delegate)
            
            photoOutput.capturePhoto(with: photoSettings, delegate: delegate)
        }
    }
    
    // MARK: - Create a photo settings object.
    
    private func createPhotoSettings(with features: EnabledPhotoFeatures, settings: CoreSettingsController) -> AVCapturePhotoSettings {
        var photoSettings = AVCapturePhotoSettings()
        
        if photoOutput.availablePhotoCodecTypes.contains(.hevc) {
            photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
        }
        
        if let previewPhotoPixelFormatType = photoSettings.availablePreviewPhotoPixelFormatTypes.first {
            photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPhotoPixelFormatType]
        }
       
        photoSettings.maxPhotoDimensions = photoOutput.maxPhotoDimensions
        
        // Use flash mode from CoreSettingsController
        photoSettings.flashMode = settings.flashMode
        
        // Use HDR settings from CoreSettingsController
        if settings.hdrVideo {
            photoSettings.maxPhotoDimensions = photoOutput.maxPhotoDimensions
        } else {
            // Define a lower resolution if HDR is not needed
            photoSettings.maxPhotoDimensions = CMVideoDimensions(width: 1920, height: 1080)
        }
        
        photoSettings.livePhotoMovieFileURL = features.isLivePhotoEnabled ? generateMovieFileURL() : nil
        
        if let prioritization = AVCapturePhotoOutput.QualityPrioritization(rawValue: features.qualityPrioritization.rawValue) {
            photoSettings.photoQualityPrioritization = prioritization
        }
        
        return photoSettings
    }
    
    private func monitorProgress(of delegate: PhotoCaptureDelegate) {
        Task {
            var isLivePhoto = false
            for await activity in delegate.activityStream {
                var currentActivity = activity
                if activity.isLivePhoto != isLivePhoto {
                    isLivePhoto = activity.isLivePhoto
                    livePhotoCount += isLivePhoto ? 1 : -1
                    if livePhotoCount > 1 {
                        currentActivity = .photoCapture(willCapture: activity.willCapture, isLivePhoto: true)
                    }
                }
                captureActivity = currentActivity
            }
        }
    }
    
    // MARK: - Update the photo output configuration
    
    func updateConfiguration(for device: AVCaptureDevice) {
        photoOutput.maxPhotoDimensions = device.activeFormat.supportedMaxPhotoDimensions.last ?? .zero
        photoOutput.isLivePhotoCaptureEnabled = photoOutput.isLivePhotoCaptureSupported
        photoOutput.maxPhotoQualityPrioritization = .quality
        photoOutput.isResponsiveCaptureEnabled = photoOutput.isResponsiveCaptureSupported
        photoOutput.isFastCapturePrioritizationEnabled = photoOutput.isFastCapturePrioritizationSupported
        photoOutput.isAutoDeferredPhotoDeliveryEnabled = photoOutput.isAutoDeferredPhotoDeliverySupported
        updateCapabilities(for: device)
    }
    
    private func updateCapabilities(for device: AVCaptureDevice) {
        capabilities = CaptureCapabilities(isFlashSupported: device.isFlashAvailable,
                                           isLivePhotoCaptureSupported: photoOutput.isLivePhotoCaptureSupported)
    }

    private func generateMovieFileURL() -> URL {
        let temporaryDirectory = FileManager.default.temporaryDirectory
        let fileName = UUID().uuidString + ".mov"
        return temporaryDirectory.appendingPathComponent(fileName)
    }
}

typealias PhotoContinuation = CheckedContinuation<Photo, Error>

// MARK: - A photo capture delegate to process the captured photo.

private class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    
    private let continuation: PhotoContinuation
    
    private var isLivePhoto = false
    private var isProxyPhoto = false
    
    private var photoData: Data?
    private var livePhotoMovieURL: URL?
    
    let activityStream: AsyncStream<CaptureActivity>
    private let activityContinuation: AsyncStream<CaptureActivity>.Continuation
    
    init(continuation: PhotoContinuation, features: EnabledPhotoFeatures) {
        self.continuation = continuation
        
        let (activityStream, activityContinuation) = AsyncStream.makeStream(of: CaptureActivity.self)
        self.activityStream = activityStream
        self.activityContinuation = activityContinuation
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, willBeginCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        isLivePhoto = !(resolvedSettings.livePhotoMovieDimensions.width == 0 && resolvedSettings.livePhotoMovieDimensions.height == 0)
        activityContinuation.yield(.photoCapture(isLivePhoto: isLivePhoto))
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        activityContinuation.yield(.photoCapture(willCapture: true, isLivePhoto: isLivePhoto))
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishRecordingLivePhotoMovieForEventualFileAt outputFileURL: URL, resolvedSettings: AVCaptureResolvedPhotoSettings) {
        activityContinuation.yield(.photoCapture(isLivePhoto: false))
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingLivePhotoToMovieFileAt outputFileURL: URL, duration: CMTime, photoDisplayTime: CMTime, resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?) {
        if let error {
            print("Error processing Live Photo companion movie: \(String(describing: error))")
        }
        livePhotoMovieURL = outputFileURL
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishCapturingDeferredPhotoProxy deferredPhotoProxy: AVCaptureDeferredPhotoProxy?, error: Error?) {
        if let error = error {
            print("Error capturing deferred photo: \(error)")
            return
        }
        photoData = deferredPhotoProxy?.fileDataRepresentation()
        isProxyPhoto = true
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Error capturing photo: \(String(describing: error))")
            return
        }
        photoData = photo.fileDataRepresentation()
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?) {

        defer {
            activityContinuation.finish()
        }

        if let error {
            continuation.resume(throwing: error)
            return
        }
        
        guard let photoData else {
            continuation.resume(throwing: PhotoCaptureError.noPhotoData)
            return
        }
        
        let photo = Photo(data: photoData, isProxy: isProxyPhoto, livePhotoMovieURL: livePhotoMovieURL)
        continuation.resume(returning: photo)
    }
}
