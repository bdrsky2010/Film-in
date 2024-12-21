//
//  HomeView.swift
//  Film-in
//
//  Created by Minjae Kim on 9/26/24.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel
    
    @State private var visibility: Visibility = .visible
    @State private var isHomeAppear = true
    @State private var isDetailDisappear = false
    @State private var index = 0
    @State private var showDetailView = false
    @State private var movie: MovieData?
    @State private var cellSize: CGSize = .zero
    @State private var posterSize: CGSize = .zero
    
    @Namespace private var namespace
    
    init(viewModel: HomeViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // poster size 1 x 1.5
    var body: some View {
        NavigationStack {
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
                .onAppear { isHomeAppear = true }
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
        .toolbar(visibility, for: .tabBar)
        .animation(.easeInOut, value: visibility)
        .valueChanged(value: isDetailDisappear) { _ in
            if isHomeAppear && isDetailDisappear { visibility = .visible }
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
            ZStack {
                NavigationLink {
                    LazyView(MovieDetailFactory.makeView(movie: movie, posterSize: posterSize))
                        .onAppear(perform: detailAppear)
                        .onDisappear(perform: detailDisappear)
                } label: {
                    let url = URL(string: ImageURL.tmdb(image: movie.poster).urlString)
                    PosterImage(url: url, size: posterSize, title: movie.title, isDownsampling: true)
                }
                .buttonStyle(.plain)
            }
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
                    NavigationLink {
                        LazyView(MovieDetailFactory.makeView(movie: movie, posterSize: posterSize))
                            .onAppear {
                                if visibility == .visible { visibility = .hidden }
                            }
                        
                    } label: {
                        let url = URL(string: ImageURL.tmdb(image: movie.poster).urlString)
                        PosterImage(url: url, size: cellSize, title: movie.title, isDownsampling: true)
                            .padding(.bottom, 4)
                            .padding(.horizontal, 8)
                    }
                    .buttonStyle(.plain)
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
                    NavigationLink {
                        LazyView(MovieDetailFactory.makeView(movie: movie, posterSize: posterSize))
                            .onAppear {
                                if visibility == .visible { visibility = .hidden }
                            }
                        
                    } label: {
                        let url = URL(string: ImageURL.tmdb(image: movie.poster).urlString)
                        PosterImage(url: url, size: cellSize, title: movie.title, isDownsampling: true)
                            .padding(.bottom, 4)
                            .padding(.horizontal, 8)
                    }
                    .buttonStyle(.plain)
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
                    NavigationLink {
                        LazyView(MovieDetailFactory.makeView(movie: movie, posterSize: posterSize))
                            .onAppear {
                                if visibility == .visible { visibility = .hidden }
                            }
                        
                    } label: {
                        let url = URL(string: ImageURL.tmdb(image: movie.poster).urlString)
                        PosterImage(url: url, size: cellSize, title: movie.title, isDownsampling: true)
                            .padding(.bottom, 4)
                            .padding(.horizontal, 8)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
        }
        .scrollIndicators(.hidden)
    }
    
    @ViewBuilder
    private func detailView(by movie: MovieData) -> some View {
        MovieDetailFactory.makeView(
            movie: movie,
            showDetailView: $showDetailView,
            namespace: namespace,
            posterSize: posterSize
        )
    }
}

extension HomeView {
    private func detailAppear() {
        if visibility == .visible {
            visibility = .hidden
        }
        isHomeAppear = false
        isDetailDisappear = false
    }
    
    private func detailDisappear() {
        isDetailDisappear = true
    }
}
