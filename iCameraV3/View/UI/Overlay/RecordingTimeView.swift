//
//  RecordingTimeView.swift
//  iCameraV3
//
//  Created by Ima Da Costa on 03/08/2024.
//

import SwiftUI

/// A view that displays the current recording time.
struct RecordingTimeView: View { // Assuming PlatformView is a typealias or unnecessary in this context

    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    let time: TimeInterval
    
    var body: some View {
        Text(time.formatted)
            .padding([.leading, .trailing], 12)
            .padding([.top, .bottom], isRegularSize ? 8 : 0)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.red.opacity(0.8), Color.red.opacity(0.4), Color.red.opacity(0.8)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .foregroundColor(.white)
            .font(.title2.weight(.semibold))
            .clipShape(Capsule())
            .opacity(0.8) // Apply opacity to the entire view
    }
    
    /// Determines if the UI should use a regular size layout.
    var isRegularSize: Bool {
        verticalSizeClass == .regular && horizontalSizeClass == .regular
    }
}

extension TimeInterval {
    var formatted: String {
        let time = Int(self)
        let seconds = time % 60
        let minutes = (time / 60) % 60
        let hours = (time / 3600)
        let formatString = "%0.2d:%0.2d:%0.2d"
        return String(format: formatString, hours, minutes, seconds)
    }
}

#Preview {
    RecordingTimeView(time: TimeInterval(floatLiteral: 500))
        .padding()
}
