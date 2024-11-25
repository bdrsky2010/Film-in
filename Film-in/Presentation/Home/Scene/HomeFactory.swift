//
//  HomeFactory.swift
//  Film-in
//
//  Created by Minjae Kim on 11/25/24.
//

import SwiftUI

enum HomeFactory {
    static func makeView() -> some View {
        HomeView(
            viewModel: HomeViewModel(
                homeService: DefaultHomeService(
                    tmdbRepository: DefaultTMDBRepository.shared,
                    databaseRepository: RealmRepository.shared
                ),
                networkMonitor: NetworkMonitor.shared
            )
        )
    }
}
