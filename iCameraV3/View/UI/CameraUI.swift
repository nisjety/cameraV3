//
//  CameraUI.swift
//  iCameraV3
//
//  Created by Ima Da Costa on 25/07/2024.
//

import SwiftUI
import AVFoundation

struct CameraUI: View {
    @StateObject var camera = CameraModel()
    @Binding var swipeDirection: SwipeDirection

    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    @State private var componentSpacing: CGFloat = 285
    @State private var componentOffset: CGFloat = 75

    var body: some View {
        ZStack {
            PreviewContainer(camera: camera) {
                CameraPreview(previewLayer: camera.previewLayer)
            }
            .gesture(swipeGesture)
            .gesture(magnificationGesture)
            .onTapGesture {
                // Obtain the tap location
                let location = CGPoint(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY)
                camera.focus(at: location)
                camera.exposure(at: location)
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }

            VStack(spacing: componentSpacing) {
                TopControls(camera: camera)
                    .offset(y: componentOffset)
                Spacer()
                CaptureControls(camera: camera)
                    .offset(y: componentOffset)
                    .padding(.bottom, bottomPadding)
            }
        }
        .edgesIgnoringSafeArea(.all)
    }

    var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 50)
            .onEnded { value in
                swipeDirection = value.translation.width < 0 ? .left : .right
            }
    }

    var magnificationGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                camera.zoom(scale: value)
            }
    }

    var bottomPadding: CGFloat {
        let bounds = UIScreen.main.bounds
        let rect = calculateRect(aspectRatio: CGSize(width: 16, height: 9), insideRect: bounds)
        return (rect.minY.rounded() / 2) + 12
    }

    func calculateRect(aspectRatio: CGSize, insideRect rect: CGRect) -> CGRect {
        let scale = min(rect.width / aspectRatio.width, rect.height / aspectRatio.height)
        let width = aspectRatio.width * scale
        let height = aspectRatio.height * scale
        let x = (rect.width - width) / 2.0
        let y = (rect.height - height) / 2.0
        return CGRect(x: x, y: y, width: width, height: height)
    }
}

struct CameraUI_Previews: PreviewProvider {
    static var previews: some View {
        CameraUI(swipeDirection: .constant(.none))
            .previewDevice("iPhone 15 Pro")
            .previewDisplayName("iPhone 15 Pro")
            .previewLayout(.device)
            .environment(\.verticalSizeClass, .regular)
            .environment(\.horizontalSizeClass, .compact)
    }
}
