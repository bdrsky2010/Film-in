//
//  MovieListFactory.swift
//  Film-in
//
//  Created by Minjae Kim on 11/25/24.
//

import SwiftUI

enum MultiListFactory {
    static func makeView(
        to usedTo: UsedTo,
        isShowAlert: Binding<Bool>,
        isRefresh: Binding<Bool>
    ) -> some View {
        MultiListView(
            viewModel: MultiListViewModel(
                multiListService: DefaultMultiListService(
                    tmdbRepository: DefaultTMDBRepository.shared,
                    databaseRepository: RealmRepository.shared
                ),
                networkMonitor: NetworkMonitor.shared,
                usedTo: usedTo),
            isShowAlert: isShowAlert,
            isRefresh: isRefresh
        )
    }
}
