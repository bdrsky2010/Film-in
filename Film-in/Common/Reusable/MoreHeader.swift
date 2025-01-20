//
//  MoreHeader.swift
//  Film-in
//
//  Created by Minjae Kim on 12/19/24.
//

import SwiftUI

struct MoreHeader: View {
    let usedTo: UsedTo
    
    var body: some View {
        HStack(alignment: .lastTextBaseline) {
            Text(usedTo.title)
                .font(.ibmPlexMonoSemiBold(size: 24))
                .foregroundStyle(.appText)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
            NavigationLink {
                LazyView(
                    SeeMoreView(usedTo: usedTo)
                )
            } label: {
                Text("more")
                    .font(.ibmPlexMonoSemiBold(size: 16))
                    .underline()
                    .foregroundStyle(.app)
            }
        }
        .padding(.horizontal, 20)
    }
}
