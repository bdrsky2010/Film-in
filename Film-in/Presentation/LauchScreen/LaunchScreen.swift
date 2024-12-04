//
//  LaunchScreen.swift
//  Film-in
//
//  Created by Minjae Kim on 12/3/24.
//

import SwiftUI

struct LaunchScreen: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct WaveTransitionTextView: View {
    @State private var isVisible: Bool = false
    let text: String = "Film-in"

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(text.enumerated()), id: \.offset) { index, letter in
                Text(String(letter))
                    .font(.ibmPlexMonoSemiBold(size: 50))
                    .foregroundStyle(.app)
                    .opacity(isVisible ? 1 : 0)
                    .offset(y: isVisible ? 0 : 30)
                    .animation(
                        .easeInOut(duration: 0.5)
                            .delay(0.1 * Double(index)),
                        value: isVisible
                    )
            }
        }
        .onAppear {
            isVisible = true
        }
    }
}

#Preview {
    LaunchScreen()
}
