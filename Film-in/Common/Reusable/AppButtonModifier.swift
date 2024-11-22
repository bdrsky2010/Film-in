//
//  AppButtonModifier.swift
//  Film-in
//
//  Created by Minjae Kim on 11/22/24.
//

import SwiftUI

extension View {
    func appButtonText() -> some View {
        self.modifier(AppButtonModifier())
    }
}

fileprivate struct AppButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.ibmPlexMonoSemiBold(size: 20))
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .background(Color(uiColor: .app).opacity(0.3))
            .foregroundStyle(.app)
    }
}
