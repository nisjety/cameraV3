import SwiftUI

struct DropDownMenu: View {
    @State private var isMenuOpen = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Menu button with three stripes
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isMenuOpen.toggle()
                }
            }) {
                ZStack {
                    Circle()
                        .fill(Color.gray.opacity(0.1))
                        .frame(width: 50, height: 50)
                    Image(systemName: "line.3.horizontal")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue.opacity(1), Color.blue.opacity(0.65), Color.blue.opacity(1)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .padding()
                }
            }
            .overlay(
                VStack {
                    if isMenuOpen {
                        VStack(spacing: 0) {
                            MenuItem(title: "Login", iconName: "person.crop.circle") {
                                print("Login tapped")
                            }
                            Divider()
                            MenuItem(title: "Subscriptions", iconName: "dollarsign.circle") {
                                print("Subscriptions tapped")
                            }
                            Divider()
                            MenuItem(title: "Cloud", iconName: "icloud") {
                                print("Cloud tapped")
                            }
                            Divider()
                            MenuItem(title: "Switch Data/Apple ID", iconName: "person.crop.circle.badge.exclamationmark") {
                                print("Switch Data/Apple ID tapped")
                            }
                            Divider()
                            MenuItem(title: "Other Options", iconName: "ellipsis.circle") {
                                print("Other options tapped")
                            }
                        }
                        .frame(width: 200) // Set the width of the dropdown menu
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .animation(.easeInOut(duration: 0.2), value: isMenuOpen)
                    }
                }
                .offset(x: 55, y: 60), // Adjust the offset to position the menu below the button
                alignment: .top
            )
        }
        .background(
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    // Do nothing, just prevent the menu from closing when tapping the menu itself
                }
        )
    }
}

// Individual menu item
struct MenuItem: View {
    let title: String
    let iconName: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: iconName)
                    .foregroundColor(.blue)
                Text(title)
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding()
        }
        .background(Color(.systemBackground))
    }
}

struct DropDownMenu_Previews: PreviewProvider {
    static var previews: some View {
        DropDownMenu()
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
