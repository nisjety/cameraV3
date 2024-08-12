import SwiftUI
import PhotosUI

/// A view that displays a thumbnail of the last captured media.
///
/// Tapping the view opens the Photos picker.
struct ThumbnailButton<CameraModel: Camera & ObservableObject>: View {
    @ObservedObject var camera: CameraModel
    @State private var selectedItems: [PhotosPickerItem] = []

    var body: some View {
        PhotosPicker(
            selection: $selectedItems,
            matching: .images,
            photoLibrary: .shared()
        ) {
            Group {
                if let thumbnail = camera.thumbnail {
                    // Assuming we want a placeholder for the actual image for the preview purpose
                    Image(systemName: "photo") // Placeholder for actual thumbnail image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: mediumButtonSize.width, height: mediumButtonSize.height)
                        .cornerRadius(2)
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue.opacity(1), Color.blue.opacity(0.65), Color.blue.opacity(1)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .animation(.easeInOut(duration: 0.3), value: camera.thumbnail)
                } else {
                    Image(systemName: "photo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: mediumButtonSize.width, height: mediumButtonSize.height)
                        .cornerRadius(8)
                        .foregroundColor(.blue)
                }
            }
        }
        .disabled(camera.captureActivity.isRecording)
    }
}

#Preview {
    ThumbnailButton(camera: PreviewCameraModel())
        .padding()
        .previewDevice("iPhone 15 Pro")
        .previewDisplayName("iPhone 15 Pro")
}
