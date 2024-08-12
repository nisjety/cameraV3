import SwiftUI

struct QuickSettingsToolbar: View {
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Binding var settingsOptions: [QuickSettingOption]
    @State private var selectedOption: QuickSettingOption?

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 10) {
                    Spacer(minLength: UIScreen.main.bounds.width / 2 - 50)
                    ForEach(settingsOptions.indices, id: \.self) { index in
                        let option = settingsOptions[index]
                        VStack {
                            Image(systemName: option.icon)
                                .font(.title2)
                                .foregroundColor(option.active ? .blue : .gray)
                            Text(option.name)
                                .font(.caption)
                                .foregroundColor(option.active ? .blue : .gray)
                        }
                        .scaleEffect(option.active ? 1.0 : 0.9)
                        .onTapGesture {
                            withAnimation {
                                toggleOption(at: index)
                                proxy.scrollTo(option.id, anchor: .center)
                            }
                        }
                        .id(option.id) // Set the id for scrolling
                        .containerRelativeFrame(.horizontal, count: verticalSizeClass == .regular ? 4 : 4, spacing: 27)
                    }
                    Spacer(minLength: UIScreen.main.bounds.width / 2 - 50)
                }
                .scrollTargetBehavior(.viewAligned)
                .scrollTargetLayout()
            }
            .frame(height: 70) // Adjust height as needed
            .onAppear {
                // Scroll to the "Live Photo" mode on appearance
                DispatchQueue.main.async {
                    if let livePhotoOption = settingsOptions.first(where: { $0.name == "Live Photo" }) {
                        proxy.scrollTo(livePhotoOption.id, anchor: .center)
                    }
                }
            }
        }
    }

    private func toggleOption(at index: Int) {
        let option = settingsOptions[index]
        if !option.active {
            deactivateConflictingOptions(for: option)
            settingsOptions[index].active = true
            settingsOptions[index].showIndicator = true
            // Hide indicator after 5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                settingsOptions[index].showIndicator = false
            }
        } else {
            settingsOptions[index].active.toggle()
        }
        settingsOptions[index].action()
    }

    private func deactivateConflictingOptions(for option: QuickSettingOption) {
        for i in settingsOptions.indices {
            if option.conflictsWith.contains(settingsOptions[i].name) {
                settingsOptions[i].active = false
            }
        }
    }
}

struct QuickSettingsToolbar_Previews: PreviewProvider {
    static var previews: some View {
        QuickSettingsToolbar(settingsOptions: .constant(QuickSettingOption.Options.all))
            .previewLayout(.sizeThatFits)
    }
}
