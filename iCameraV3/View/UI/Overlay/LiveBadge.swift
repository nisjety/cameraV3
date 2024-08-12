//
//  LiveBadge.swift
//  iCameraV3
//
//  Created by Ima Da Costa on 03/08/2024.
//

import SwiftUI

/// A view that the app presents to indicate that Live Photo capture is active.
struct LiveBadge: View {
    var body: some View {
        Text("LIVE")
            .frame(width: 31, height: 10)
            .padding(3)
            .foregroundColor(.white)
            .font(.subheadline)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.blue.opacity(0.4), Color.blue.opacity(0.8)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(2) // Adding a corner radius for rounded edges
            .opacity(0.8) // Set the opacity for the entire badge
    }
}

#Preview {
    LiveBadge()
        .padding()
}
