//
//  SettingsButton.swift
//  iCameraV3
//
//  Created by Ima Da Costa on 07/08/2024.
//

import SwiftUI

struct SettingsButton: View {
    @Binding var isShowingSettings: Bool

    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.3)) {
                isShowingSettings.toggle()
            }
        })  {
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 50, height: 50)
                Image(systemName: "gearshape")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: xmediumButtonSize.width, height: xmediumButtonSize.height)
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
        .padding()
    }
}

struct SettingsButton_Previews: PreviewProvider {
    static var previews: some View {
        SettingsButton(isShowingSettings: .constant(false))
            .previewLayout(.sizeThatFits)
            .padding()
            .background(Color.gray.opacity(0.1))
    }
}
