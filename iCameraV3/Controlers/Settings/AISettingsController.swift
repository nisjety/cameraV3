//
//  AISettingsController.swift
//  iCamera
//
//  Created by Ima Da Costa on 24/06/2024.
//

import Foundation
import Combine

class AISettingsController: ObservableObject {
    @Published var isFaceDetectionEnabled: Bool = true
    @Published var isAISceneRecognitionEnabled: Bool = false
    @Published var isAutoFocusOnFacesEnabled: Bool = true
    @Published var isFocusing: Bool = false
}
