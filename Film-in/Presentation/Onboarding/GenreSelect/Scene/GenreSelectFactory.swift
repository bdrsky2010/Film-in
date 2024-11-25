//
//  GenreSelectFactory.swift
//  Film-in
//
//  Created by Minjae Kim on 11/24/24.
//

import SwiftUI

enum GenreSelectFactory {
    static func makeView() -> some View {
        GenreSelectView(
            viewModel: GenreSelectViewModel(
                genreSelectService: DefaultGenreSelectService(
                    tmdbRepository: DefaultTMDBRepository.shared,
                    databaseRepository: RealmRepository.shared
                ),
                networkMonitor: NetworkMonitor.shared
            )
        )
    }
}
