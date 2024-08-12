
//  CameraTypeChoice.swift

import SwiftUI
import Foundation

import SwiftUI
import Foundation

// Model for camera modes
struct Mode: Identifiable, Equatable {
    let name: String
    let id = UUID()
    
    // Static method to provide a list of modes
    struct CameraMode {
        static let modes = [
            Mode(name: "Time-Lapse"),
            Mode(name: "Slo-Mo"),
            Mode(name: "Filmatick"),
            Mode(name: "Photo"),
            Mode(name: "Video"),
            Mode(name: "Portrait"),
            Mode(name: "Panorama")
        ]
    }
}

// View for choosing camera type
struct CameraTypeChoice: View {
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Binding var selectedMode: Mode
    @State private var scrollPosition: UUID?

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 10) {
                    Spacer(minLength: UIScreen.main.bounds.width / 2 - 50)
                    ForEach(Mode.CameraMode.modes) { mode in
                        Text(mode.name)
                            .foregroundStyle(selectedMode.id == mode.id ? Color.blue : Color.gray)
                            .opacity(selectedMode.id == mode.id ? 1.0 : 0.6)
                            .scaleEffect(selectedMode.id == mode.id ? CGSize(width: 1.0, height: 1.0) : CGSize(width: 0.9, height: 0.9))
                            .onTapGesture {
                                withAnimation {
                                    selectedMode = mode
                                    proxy.scrollTo(selectedMode.id, anchor: .center)
                                }
                            }
                            .id(mode.id) // Set the id for scrolling
                            .containerRelativeFrame(.horizontal, count: verticalSizeClass == .regular ? 4 : 4, spacing: 27)
                    }
                    Spacer(minLength: UIScreen.main.bounds.width / 2 - 50)
                }
                .scrollTargetBehavior(.viewAligned)
                .scrollTargetLayout()
                .scrollPosition(id: $scrollPosition)
                .onChange(of: scrollPosition) { _, newPosition in
                    if let newPosition, let mode = Mode.CameraMode.modes.first(where: { $0.id == newPosition }) {
                        selectedMode = mode
                    }
                }
            }
            .frame(height: 20)
            .onAppear {
                // Scroll to the "Photo" mode on appearance
                DispatchQueue.main.async {
                    proxy.scrollTo(selectedMode.id, anchor: .center)
                }
            }
        }
    }
}

// Preview provider for CameraTypeChoice view
struct CameraTypeChoice_Previews: PreviewProvider {
    @State static var selectedMode = Mode.CameraMode.modes.first { $0.name == "Photo" }!

    static var previews: some View {
        CameraTypeChoice(selectedMode: $selectedMode)
    }
}
