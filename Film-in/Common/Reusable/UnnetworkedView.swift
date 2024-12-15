//
//  UnnetworkedView.swift
//  Film-in
//
//  Created by Minjae Kim on 11/25/24.
//

import SwiftUI

struct UnnetworkedView: View {
    private let refreshAction: () -> Void
    
    init(refreshAction: @autoclosure @escaping () -> Void) {
        self.refreshAction = refreshAction
    }
    
    var body: some View {
        VStack {
            Image(systemName: "wifi.slash")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundStyle(.app)
            
            Text("notConnectInternet")
                .font(.ibmPlexMonoSemiBold(size: 20))
                .foregroundStyle(.appText)
            
            Button {
                withAnimation {
                    refreshAction()
                }
            } label: {
                Text("refresh")
                    .font(.ibmPlexMonoMedium(size: 20))
                    .underline()
                    .foregroundStyle(.app)
            }
        }
    }
}
