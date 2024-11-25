//
//  UnnetworkedView.swift
//  Film-in
//
//  Created by Minjae Kim on 11/25/24.
//

import SwiftUI

struct UnnetworkedView: View {
    private var refrshAction: (() -> Void)?
    
    init(refrshAction: (() -> Void)? = nil) {
        self.refrshAction = refrshAction
    }
    
    var body: some View {
        VStack {
            Text("notConnectInternet")
                .font(.ibmPlexMonoSemiBold(size: 20))
                .foregroundStyle(.appText)
            Button {
                withAnimation {
                    refrshAction?()
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
