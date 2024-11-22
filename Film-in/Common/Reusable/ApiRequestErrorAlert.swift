//
//  PopupAlert.swift
//  Film-in
//
//  Created by Minjae Kim on 11/19/24.
//

import SwiftUI
import PopupView

extension View {
    func apiRequestErrorAlert(isPresented: Binding<Bool>, refreshButtonTapped: (() -> Void)? = nil) -> some View {
        self.modifier(ApiRequestErrorAlertViewModifier(isPresented: isPresented, refreshButtonTapped: refreshButtonTapped))
    }
}

fileprivate struct ApiRequestErrorAlertViewModifier: ViewModifier {
    @Binding var isPresented: Bool
    
    var refreshButtonTapped: (() -> Void)?
    
    func body(content: Content) -> some View {
        content
            .popup(isPresented: $isPresented) {
                ApiRequestErrorAlert(refreshButtonTapped: refreshButtonTapped)
            } customize: {
                $0
                    .type(.floater())
                    .isOpaque(true)
                    .animation(.bouncy)
                    .position(.top)
                    .dragToDismiss(true)
            }
    }
}

fileprivate struct ApiRequestErrorAlert: View {
    var refreshButtonTapped: (() -> Void)?
    
    init(refreshButtonTapped: (() -> Void)? = nil) {
        self.refreshButtonTapped = refreshButtonTapped
    }
    
    var body: some View {
        VStack {
            Text("apiRequestError")
                .font(.ibmPlexMonoSemiBold(size: 20))
                .padding(.top)
            Button {
                refreshButtonTapped?()
            } label: {
                Text("refresh")
                    .font(.ibmPlexMonoMedium(size: 20))
                    .underline()
                    .foregroundStyle(.white)
            }
        }
        .padding(.horizontal)
        .padding(.bottom)
        .background(.app)
    }
}
