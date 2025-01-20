//
//  SeeMoreView.swift
//  Film-in
//
//  Created by Minjae Kim on 9/30/24.
//

import SwiftUI

struct SeeMoreView: View {
    
    @State private var isShowAlert = false
    @State private var isRefresh = false
    
    init(usedTo: UsedTo) {
        self.usedTo = usedTo
    }
    let usedTo: UsedTo
    
    var body: some View {
        MultiListFactory.makeView(
            to: usedTo,
            isShowAlert: $isShowAlert,
            isRefresh: $isRefresh
        )
        .popupAlert(
            isPresented: $isShowAlert,
            contentModel: .init(
                systemImage: "wifi.exclamationmark",
                phrase: "apiRequestError",
                normal: "refresh"
            ),
            heightType: .middle
        ){
            isRefresh = true
        }
        .toolbar(.hidden, for: .tabBar)
    }
}
