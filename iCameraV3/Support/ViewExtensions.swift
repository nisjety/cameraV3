//
//  ViewExtensions.swift
//  iCameraV3
//
//  Created by Ima Da Costa on 03/08/2024.
//

import Foundation
import SwiftUI
import UIKit

let xlargeButtonSize = CGSize(width: 128, height: 128)
let largeButtonSize = CGSize(width: 64, height: 64)
let xmediumButtonSize = CGSize(width: 30, height: 28)
let lmediumButtonSize = CGSize(width: 26, height: 25)
let mediumButtonSize = CGSize(width: 28, height: 22)
let smallButtonSize = CGSize(width: 16, height: 16)
let xsmallButtonSize = CGSize(width: 8, height: 8)

@MainActor
protocol PlatformView: View {
    var verticalSizeClass: UserInterfaceSizeClass? { get }
    var horizontalSizeClass: UserInterfaceSizeClass? { get }
    var isRegularSize: Bool { get }
    var isCompactSize: Bool { get }
}

extension PlatformView {
    var isRegularSize: Bool { horizontalSizeClass == .regular && verticalSizeClass == .regular }
    var isCompactSize: Bool { horizontalSizeClass == .compact || verticalSizeClass == .compact }
}

/// A container view for the app's toolbars that lays the items out horizontally
/// on iPhone and vertically on iPad and Mac Catalyst.
struct AdaptiveToolbar<Content: View>: PlatformView {
    
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    private let horizontalSpacing: CGFloat
    private let verticalSpacing: CGFloat
    private let content: Content
    
    init(horizontalSpacing: CGFloat = 0.0, verticalSpacing: CGFloat = 0.0, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.horizontalSpacing = horizontalSpacing
        self.verticalSpacing = verticalSpacing
    }
    
    var body: some View {
        if isRegularSize {
            VStack(spacing: verticalSpacing) { content }
        } else {
            HStack(spacing: horizontalSpacing) { content }
        }
    }
}

struct DefaultButtonStyle: ButtonStyle {
    
    @Environment(\.isEnabled) private var isEnabled: Bool
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    enum Size: CGFloat {
        case small = 22
        case large = 24
    }
    
    private let size: Size
    
    init(size: Size) {
        self.size = size
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(isEnabled ? .primary : Color(white: 0.4))
            .font(.system(size: size.rawValue))
            .padding(isRegularSize || size == .large ? 10.0 : 0)
            .clipShape(size == .small ? AnyShape(Rectangle()) : AnyShape(Circle()))
    }
    
    var isRegularSize: Bool {
        horizontalSizeClass == .regular && verticalSizeClass == .regular
    }
}

extension View {
    func debugBorder(color: Color = .red) -> some View {
        self
            .border(color)
    }
}

extension Image {
    init(_ image: CGImage) {
        self.init(uiImage: UIImage(cgImage: image))
    }
}
