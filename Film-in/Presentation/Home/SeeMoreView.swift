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
    let viewModel: MultiListViewModel
    
    var body: some View {
        MultiListView(
            viewModel: viewModel,
            isShowAlert: $isShowAlert,
            isRefresh: $isRefresh
        )
        .popupAlert(
            isPresented: $isShowAlert,
            contentModel: .init(
                systemImage: R.AssetImage.wifi,
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
