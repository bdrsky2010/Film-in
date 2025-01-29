//
//  HomeView.swift
//  Film-in
//
//  Created by Minjae Kim on 9/26/24.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var coordinator: Coordinator
    
    @StateObject private var viewModel: HomeViewModel
    
    @State private var index = 0
    @State private var cellSize: CGSize = .zero
    @State private var posterSize: CGSize = .zero
    
    init(viewModel: HomeViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    // poster size 1 x 1.5
    var body: some View {
        VStack {
            if !viewModel.output.networkConnect {
                UnnetworkedView(refreshAction: viewModel.action(.refresh))
            } else {
                GeometryReader { proxy in
                    VStack {
                        appTitleSection()
                        
                        ScrollView {
                            trendingSection()
                            nowPlayingSection()
                            upcomingSection()
                            recommendSection()
                        }
                        .scrollIndicators(.hidden)
                        .refreshable {
                            viewModel.action(.refresh)
                        }
                    }
                    .task {
                        if posterSize == .zero {
                            posterSize = CGSize(
                                width: proxy.size.width * 0.7,
                                height: proxy.size.width * 0.7 * 1.5
                            )
                        }
                        
                        if cellSize == .zero {
                            cellSize = CGSize(
                                width: posterSize.width * 0.5,
                                height: posterSize.height * 0.5
                            )
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .task { viewModel.action(.viewOnTask) }
                .popupAlert(
                    isPresented: Binding(
                        get: { viewModel.output.isShowAlert },
                        set: { _ in viewModel.action(.onDismissAlert) }
                    ),
                    contentModel: .init(
                        systemImage: "wifi.exclamationmark",
                        phrase: "apiRequestError",
                        normal: "refresh"
                    ),
                    heightType: .middle
                ) {
                    viewModel.action(.refresh)
                }
            }
        }
    }
}

extension HomeView {
    @ViewBuilder
    private func appTitleSection() -> some View {
        Text(verbatim: "Film-in")
            .font(.ibmPlexMonoSemiBold(size: 50))
            .foregroundStyle(.app)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .frame(height: 50)
    }
    
    @ViewBuilder
    private func trendingSection() -> some View {
        PagingView(currentIndex: $index, items: viewModel.output.trendingMovies.movies) { movie in
            posterButton(movie: movie, size: posterSize)
        }
        .frame(height: posterSize.height)
        .padding(.bottom, 20)
    }
    
    @ViewBuilder
    private func nowPlayingSection() -> some View {
        MoreHeader(usedTo: .nowPlaying)
        
        ScrollView(.horizontal) {
            LazyHStack(spacing: 8) {
                ForEach(viewModel.output.nowPlayingMovies.movies, id: \.id) { movie in
                    posterButton(movie: movie, size: cellSize)
                }
            }
            .padding(.horizontal)
        }
        .scrollIndicators(.hidden)
    }
    
    @ViewBuilder
    private func upcomingSection() -> some View {
        MoreHeader(usedTo: .upcoming)
        
        ScrollView(.horizontal) {
            LazyHStack(spacing: 8) {
                ForEach(viewModel.output.upcomingMovies.movies, id: \.id) { movie in
                    posterButton(movie: movie, size: cellSize)
                }
            }
            .padding(.horizontal)
        }
        .scrollIndicators(.hidden)
    }
    
    @ViewBuilder
    private func recommendSection() -> some View {
        MoreHeader(usedTo: .recommend)
        
        ScrollView(.horizontal) {
            LazyHStack(spacing: 8) {
                ForEach(viewModel.output.recommendMovies.movies, id: \.id) { movie in
                    posterButton(movie: movie, size: cellSize)
                }
            }
            .padding(.horizontal)
        }
        .scrollIndicators(.hidden)
    }
}

extension HomeView {
    @ViewBuilder
    private func posterButton(movie: MovieData, size: CGSize) -> some View {
        
        Button {
            buttonTapped(movie: movie)
        } label: {
            buttonLabel(movie: movie, size: size)
        }
        .buttonStyle(.plain)
    }
    
    private func buttonTapped(movie: MovieData) {
        coordinator.push(.movieDetail(movie, posterSize))
    }
    
    @ViewBuilder
    private func buttonLabel(movie: MovieData, size: CGSize) -> some View {
        if size == cellSize {
            let url = URL(string: ImageURL.tmdb(image: movie.poster).urlString)
            PosterImage(url: url, size: size, title: movie.title, isDownsampling: true)
                .padding(.bottom, 4)
                .padding(.horizontal, 8)
        } else {
            let url = URL(string: ImageURL.tmdb(image: movie.poster).urlString)
            PosterImage(url: url, size: size, title: movie.title, isDownsampling: true)
        }
    }
}
