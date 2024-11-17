//
//  HomeView.swift
//  Film-in
//
//  Created by Minjae Kim on 9/26/24.
//

import SwiftUI
import PopupView

struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel
    @Namespace var namespace
    @State private var index = 0
    @State private var showDetailView = false
    @State private var movie: HomeMovie.Movie?
    @State private var posterSize: CGSize = .zero
    @State private var offset: CGFloat = 0
    
    init(viewModel: HomeViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // poster size 1 x 1.5
    var body: some View {
        NavigationStack {
            if !viewModel.output.networkConnect {
                NotConnectView(viewModel: viewModel)
            } else {
                GeometryReader { proxy in
                    VStack {
                        appTitleSection()
                        
                        ScrollView {
                            ListHeader(title: "nowPlaying", usedTo: .nowPlaying)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                LazyHStack {
                                    ForEach(viewModel.output.nowPlayingMovies.movies, id: \.id) { movie in
                                        let url = URL(string: ImageURL.tmdb(image: movie.poster).urlString)
                                        PosterImage(url: url, size: CGSize(width: posterSize.width * 0.5, height: posterSize.height * 0.5), title: movie.title)
                                            .padding(.bottom, 4)
                                            .padding(.horizontal, 8)
                                            .matchedGeometryEffect(id: movie.id, in: namespace)
                                            .onTapGesture {
                                                self.movie = movie
                                                withAnimation(.easeInOut) {
                                                    showDetailView = true
                                                }
                                            }
                                    }
                                }
                            }
                            
                            ListHeader(title: "upcoming", usedTo: .upcoming)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                LazyHStack {
                                    ForEach(viewModel.output.upcomingMovies.movies, id: \.id) { movie in
                                        let url = URL(string: ImageURL.tmdb(image: movie.poster).urlString)
                                        PosterImage(url: url, size: CGSize(width: posterSize.width * 0.5, height: posterSize.height * 0.5), title: movie.title)
                                            .padding(.bottom, 4)
                                            .padding(.horizontal, 8)
                                            .matchedGeometryEffect(id: movie.id, in: namespace)
                                            .onTapGesture {
                                                self.movie = movie
                                                withAnimation(.easeInOut) {
                                                    showDetailView = true
                                                }
                                            }
                                    }
                                }
                            }
                            
                            ListHeader(title: "recommend", usedTo: .recommend)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                LazyHStack {
                                    ForEach(viewModel.output.recommendMovies.movies, id: \.id) { movie in
                                        let url = URL(string: ImageURL.tmdb(image: movie.poster).urlString)
                                        PosterImage(url: url, size: CGSize(width: posterSize.width * 0.5, height: posterSize.height * 0.5), title: movie.title)
                                            .padding(.bottom, 4)
                                            .padding(.horizontal, 8)
                                            .matchedGeometryEffect(id: movie.id, in: namespace)
                                            .onTapGesture {
                                                self.movie = movie
                                                withAnimation(.easeInOut) {
                                                    showDetailView = true
                                                }
                                            }
                                    }
                                }
                            }
                            trendingSection()
                        }
                    }
                    .task {
                        posterSize = CGSize(width: proxy.size.width * 0.7, height: proxy.size.width * 0.7 * 1.5)
                    }
                    
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .overlay {
                    if let movie, showDetailView {
                        TransitionMovieDetailView(
                            viewModel: MovieDetailViewModel(
                                movieDetailService: DefaultMovieDetailService(
                                    tmdbRepository: DefaultTMDBRepository.shared,
                                    databaseRepository: RealmRepository.shared
                                ),
                                networkMonitor: NetworkMonitor.shared,
                                movieId: movie._id
                            ),
                            offset: $offset,
                            showDetailView: $showDetailView,
                            namespace: namespace,
                            movie: movie,
                            size: posterSize
                        )
                    }
                }
                .task {
                    withAnimation {
                        viewModel.action(.viewOnTask)
                    }
                }
                .popup(isPresented: $viewModel.output.isShowAlert) {
                    VStack {
                        Text("apiRequestError")
                            .font(.ibmPlexMonoSemiBold(size: 20))
                        Button {
                            viewModel.action(.refresh)
                        } label: {
                            Text("refresh")
                                .font(.ibmPlexMonoMedium(size: 20))
                                .underline()
                                .foregroundStyle(.white)
                        }
                        .padding(.bottom, 4)
                    }
                    .frame(maxWidth: .infinity)
                    .background(.red)
                } customize: {
                    $0
                        .type(.floater(verticalPadding: 0, horizontalPadding: 0, useSafeAreaInset: true))
                        .animation(.bouncy)
                        .position(.top)
                        .dragToDismiss(true)
                }
            }
        }
    }
    
    @ViewBuilder
    private func appTitleSection() -> some View {
        Text("Film-in")
            .font(.ibmPlexMonoSemiBold(size: 50))
            .foregroundStyle(.app)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .frame(height: 50)
    }
    
    @ViewBuilder
    private func trendingSection() -> some View {
        SnapCarousel(spacing: 28, trailingSpace: 120, index: $index, items: viewModel.output.trendingMovies.movies) { movie in
            
            let url = URL(string: ImageURL.tmdb(image: movie.poster).urlString)
            PosterImage(url: url, size: posterSize, title: movie.title)
                .matchedGeometryEffect(id: movie.id, in: namespace)
                .onTapGesture {
                    self.movie = movie
                    withAnimation(.easeInOut) {
                        showDetailView = true
                    }
                }
        }
        .frame(height: posterSize.height)
        .padding(.bottom, 20)
    }
}

fileprivate struct ListHeader: View {
    let title: LocalizedStringKey
    let usedTo: UsedTo
    
    var body: some View {
        HStack(alignment: .lastTextBaseline) {
            Text(title)
                .font(.ibmPlexMonoSemiBold(size: 24))
                .foregroundStyle(.appText)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
            NavigationLink {
                SeeMoreView(usedTo: usedTo)
            } label: {
                Text("more")
                    .font(.ibmPlexMonoSemiBold(size: 16))
                    .underline()
                    .foregroundStyle(.app)
            }
        }
        .padding(.horizontal, 20)
    }
}

fileprivate struct NotConnectView: View {
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        VStack {
            Text("notConnectInternet")
                .font(.ibmPlexMonoSemiBold(size: 20))
                .foregroundStyle(.appText)
            Button {
                withAnimation {
                    viewModel.action(.refresh)
                }
            } label: {
                Text("refresh")
                    .font(.ibmPlexMonoMedium(size: 20))
                    .underline()
                    .foregroundStyle(.app)
            }
        }
    }
}
