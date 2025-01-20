//
//  SeeMoreView.swift
//  Film-in
//
//  Created by Minjae Kim on 9/30/24.
//

import SwiftUI

struct SeeMoreView: View {
    @EnvironmentObject var diConatiner: DefaultDIContainer
    
    @State private var isShowAlert = false
    @State private var isRefresh = false
    
    let usedTo: UsedTo
    
    var body: some View {
        MultiListView(
            viewModel: diConatiner.makeMultiListViewModel(usedTo: usedTo),
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
