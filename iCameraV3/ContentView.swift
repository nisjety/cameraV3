//
//  ContentView.swift
//  iCameraV3
//
//  Created by Ima Da Costa on 25/07/2024.
//

import SwiftUI

struct ContentView: View {
    @State private var swipeDirection: SwipeDirection = .none

    var body: some View {
        CameraUI(swipeDirection: $swipeDirection)
            .edgesIgnoringSafeArea(.all)
    }
}

enum SwipeDirection {
    case left, right, none
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewDevice("iPhone 15 Pro")
            .previewDisplayName("iPhone 15 Pro")
    }
}
