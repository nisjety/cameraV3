//
//  FocusSettingsController.swift
//  iCamera
//
//  Created by Ima Da Costa on 24/06/2024.
//

import Foundation
import Combine

enum FocusMode {
    case auto
    case manual
}

class FocusSettingsController: ObservableObject {
    @Published var focusMode: FocusMode = .auto
    @Published var isRealTimeRecalibrationEnabled: Bool = false
    @Published var isZoomEnabled: Bool = true
    @Published var zoomLevel: Double = 1.0
}
