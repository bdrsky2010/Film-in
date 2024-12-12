//
//  SeeMoreView.swift
//  Film-in
//
//  Created by Minjae Kim on 9/30/24.
//

import SwiftUI

struct SeeMoreView: View {
    private let usedTo: UsedTo
    
    @State private var isShowAlert = false
    @State private var isRefresh = false
    
    init(usedTo: UsedTo) {
        self.usedTo = usedTo
    }
    
    var body: some View {
        MultiListFactory.makeView(
            to: usedTo,
            isShowAlert: $isShowAlert,
            isRefresh: $isRefresh
        )
        .apiRequestErrorAlert(isPresented: $isShowAlert) {
            isRefresh = true
        }
        .toolbar(.hidden, for: .tabBar)
    }
}
