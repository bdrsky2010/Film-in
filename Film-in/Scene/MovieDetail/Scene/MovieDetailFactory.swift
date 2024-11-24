//
//  MovieDetailFactory.swift
//  Film-in
//
//  Created by Minjae Kim on 11/24/24.
//

import SwiftUI

enum MovieDetailFactory {
    static func makeView(
        movie: HomeMovie.Movie,
        posterSize: CGSize
    ) -> some View {
        MovieDetailView(
            movie: movie,
            size: posterSize,
            viewModel: MovieDetailViewModel(
                movieDetailService: DefaultMovieDetailService(
                    tmdbRepository: DefaultTMDBRepository.shared,
                    databaseRepository: RealmRepository.shared
                ),
                networkMonitor: NetworkMonitor.shared,
                movieId: movie._id
            )
        )
    }
    
    static func makeView(
        movie: HomeMovie.Movie,
        offset: Binding<CGFloat>,
        showDetailView: Binding<Bool>,
        namespace: Namespace.ID,
        posterSize: CGSize
    ) -> some View {
        TransitionMovieDetailView(
            viewModel: MovieDetailViewModel(
                movieDetailService: DefaultMovieDetailService(
                    tmdbRepository: DefaultTMDBRepository.shared,
                    databaseRepository: RealmRepository.shared
                ),
                networkMonitor: NetworkMonitor.shared,
                movieId: movie._id
            ),
            offset: offset,
            showDetailView: showDetailView,
            namespace: namespace,
            movie: movie,
            size: posterSize
        )
    }
}
