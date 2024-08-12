//
//  MediaLibrary.swift
//  iCameraV3
//
//  Created by Ima Da Costa on 03/08/2024.
//


import Foundation
import Photos
import UIKit
import CoreLocation

/// An object that writes photos and movies to the user's Photos library.
actor MediaLibrary {
    
    private let locationManager = CLLocationManager()

    // Errors that media library can throw.
    enum Error: Swift.Error {
        case unauthorized
        case saveFailed
    }
    
    /// An asynchronous stream of thumbnail images the app generates after capturing media.
    let thumbnails: AsyncStream<CGImage?>
    private let continuation: AsyncStream<CGImage?>.Continuation?
    
    /// Creates a new media library object.
    init() {
        let (thumbnails, continuation) = AsyncStream.makeStream(of: CGImage?.self)
        self.thumbnails = thumbnails
        self.continuation = continuation
    }
    
    // MARK: - Authorization
    
    private var isAuthorized: Bool {
        get async {
            let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
            var isAuthorized = status == .authorized
            if status == .notDetermined {
                let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
                isAuthorized = status == .authorized
            }
            return isAuthorized
        }
    }

    // MARK: - Saving media
    
    /// Saves a photo to the Photos library.
    func save(photo: Photo) async throws {
        let location = try await currentLocation
        try await performChange {
            let creationRequest = PHAssetCreationRequest.forAsset()
            
            let options = PHAssetResourceCreationOptions()
            creationRequest.addResource(with: photo.isProxy ? .photoProxy : .photo, data: photo.data, options: options)
            creationRequest.location = location
            
            if let url = photo.livePhotoMovieURL {
                let livePhotoOptions = PHAssetResourceCreationOptions()
                livePhotoOptions.shouldMoveFile = true
                creationRequest.addResource(with: .pairedVideo, fileURL: url, options: livePhotoOptions)
            }
            
            return creationRequest.placeholderForCreatedAsset
        }
    }
    
    /// Saves a movie to the Photos library.
    func save(movie: Movie) async throws {
        let location = try await currentLocation
        try await performChange {
            let options = PHAssetResourceCreationOptions()
            options.shouldMoveFile = true
            let creationRequest = PHAssetCreationRequest.forAsset()
            creationRequest.addResource(with: .video, fileURL: movie.url, options: options)
            creationRequest.location = location
            return creationRequest.placeholderForCreatedAsset
        }
    }
    
    // A template method for writing a change to the user's photo library.
    private func performChange(_ change: @Sendable @escaping () -> PHObjectPlaceholder?) async throws {
        guard await isAuthorized else {
            throw Error.unauthorized
        }
        
        do {
            var placeholder: PHObjectPlaceholder?
            try await PHPhotoLibrary.shared().performChanges {
                placeholder = change()
            }
            
            if let placeholder {
                guard let asset = PHAsset.fetchAssets(withLocalIdentifiers: [placeholder.localIdentifier], options: nil).firstObject else { return }
                await createThumbnail(for: asset)
            }
        } catch {
            throw Error.saveFailed
        }
    }
    
    // MARK: - Thumbnail handling
    
    private func loadInitialThumbnail() async {
        guard PHPhotoLibrary.authorizationStatus(for: .readWrite) == .authorized else { return }
        
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        if let asset = PHAsset.fetchAssets(with: options).firstObject {
            await createThumbnail(for: asset)
        }
    }
    
    private func createThumbnail(for asset: PHAsset) async {
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        requestOptions.deliveryMode = .highQualityFormat

        PHImageManager.default().requestImage(for: asset,
                                              targetSize: .init(width: 256, height: 256),
                                              contentMode: .aspectFill,
                                              options: requestOptions) { [weak self] image, _ in
            guard let self, let image = image else { return }
            self.continuation?.yield(image.cgImage)
        }
    }
    
    // MARK: - Location management

    private var currentLocation: CLLocation? {
        get async throws {
            if locationManager.authorizationStatus == .notDetermined {
                try await locationManager.requestLocationAuthorization()
            }
            return try await withCheckedThrowingContinuation { continuation in
                locationManager.didUpdateLocations = { locations in
                    if let location = locations.first {
                        continuation.resume(returning: location)
                    } else {
                        continuation.resume(throwing: LocationError.noLocationFound)
                    }
                }
                locationManager.didFailWithError = { error in
                    continuation.resume(throwing: error)
                }
                locationManager.requestLocation()
            }
        }
    }

}
