//
//  LaunchScreen.swift
//  Film-in
//
//  Created by Minjae Kim on 12/3/24.
//

import SwiftUI

struct LaunchScreenView: View {
    @State private var isVisible = false
    @Binding var isWave: Bool
    
    private let title = "Film-in"

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(title.enumerated()), id: \.offset) { index, letter in
                Text(verbatim: String(letter))
                    .font(.ibmPlexMonoSemiBold(size: 60))
                    .foregroundStyle(.app)
                    .opacity(isVisible ? 1 : 0)
                    .offset(y: isVisible ? 0 : 30)
                    .animation(
                        .easeInOut(duration: 0.5)
                            .delay(0.1 * Double(index)),
                        value: isVisible
                    )
                    .task {
                        try? await Task.sleep(nanoseconds: 1_500_000_000)
                        withAnimation { isWave = true }
                    }
            }
        }
        .onAppear { isVisible = true }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.background)
    }
}
