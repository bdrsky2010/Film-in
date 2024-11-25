//
//  MovieListFactory.swift
//  Film-in
//
//  Created by Minjae Kim on 11/25/24.
//

import SwiftUI

enum MovieListFactory {
    static func makeView(
        to usedTo: UsedTo,
        isShowAlert: Binding<Bool>,
        isRefresh: Binding<Bool>
    ) -> some View {
        MovieListView(
            viewModel: MovieListViewModel(
                movieListService: DefaultMovieListService(
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
