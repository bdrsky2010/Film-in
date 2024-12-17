//
//  HomeView.swift
//  Film-in
//
//  Created by Minjae Kim on 9/26/24.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel
    @Namespace var namespace
    @State private var index = 0
    @State private var showDetailView = false
    @State private var movie: MovieData?
    @State private var posterSize: CGSize = .zero
    
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
                        .refreshable {
                            viewModel.action(.refresh)
                        }
                    }
                    .task {
                        posterSize = CGSize(width: proxy.size.width * 0.7, height: proxy.size.width * 0.7 * 1.5)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .overlay {
                    if let movie, showDetailView {
                        detailView(by: movie)
                    }
                }
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
        SnapCarousel(spacing: 28, trailingSpace: 120, index: $index, items: viewModel.output.trendingMovies.movies) { movie in
            
            let url = URL(string: ImageURL.tmdb(image: movie.poster).urlString)
            PosterImage(url: url, size: posterSize, title: movie.title, isDownsampling: true)
                .matchedGeometryEffect(id: movie.id, in: namespace, properties: .frame, isSource: !showDetailView)
                .onTapGesture {
                    withAnimation(.easeInOut) {
                        self.movie = movie
                        showDetailView = true
                    }
                }
        }
        .frame(height: posterSize.height)
        .padding(.bottom, 20)
    }
    
    @ViewBuilder
    private func nowPlayingSection() -> some View {
        ListHeader(localizedTitle: "nowPlaying", usedTo: .nowPlaying)
        
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack {
                ForEach(viewModel.output.nowPlayingMovies.movies, id: \.id) { movie in
                    let url = URL(string: ImageURL.tmdb(image: movie.poster).urlString)
                    PosterImage(url: url, size: CGSize(width: posterSize.width * 0.5, height: posterSize.height * 0.5), title: movie.title, isDownsampling: true)
                        .padding(.bottom, 4)
                        .padding(.horizontal, 8)
                        .matchedGeometryEffect(id: movie.id, in: namespace, properties: .frame, isSource: !showDetailView)
                        .onTapGesture {
                            withAnimation(.easeInOut) {
                                self.movie = movie
                                showDetailView = true
                            }
                        }
                }
            }
        }
    }
    
    @ViewBuilder
    private func upcomingSection() -> some View {
        ListHeader(localizedTitle: "upcoming", usedTo: .upcoming)
        
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack {
                ForEach(viewModel.output.upcomingMovies.movies, id: \.id) { movie in
                    let url = URL(string: ImageURL.tmdb(image: movie.poster).urlString)
                    PosterImage(url: url, size: CGSize(width: posterSize.width * 0.5, height: posterSize.height * 0.5), title: movie.title, isDownsampling: true)
                        .padding(.bottom, 4)
                        .padding(.horizontal, 8)
                        .matchedGeometryEffect(id: movie.id, in: namespace, properties: .frame, isSource: !showDetailView)
                        .onTapGesture {
                            withAnimation(.easeInOut) {
                                self.movie = movie
                                showDetailView = true
                            }
                        }
                }
            }
        }
    }
    
    @ViewBuilder
    private func recommendSection() -> some View {
        ListHeader(localizedTitle: "recommend", usedTo: .recommend)
        
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack {
                ForEach(viewModel.output.recommendMovies.movies, id: \.id) { movie in
                    let url = URL(string: ImageURL.tmdb(image: movie.poster).urlString)
                    PosterImage(url: url, size: CGSize(width: posterSize.width * 0.5, height: posterSize.height * 0.5), title: movie.title, isDownsampling: true)
                        .padding(.bottom, 4)
                        .padding(.horizontal, 8)
                        .matchedGeometryEffect(id: movie.id, in: namespace, properties: .frame, isSource: !showDetailView)
                        .onTapGesture {
                            withAnimation(.easeInOut) {
                                self.movie = movie
                                showDetailView = true
                            }
                        }
                }
            }
        }
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

fileprivate struct ListHeader: View {
    let localizedTitle: LocalizedStringKey
    let usedTo: UsedTo
    
    var body: some View {
        HStack(alignment: .lastTextBaseline) {
            Text(localizedTitle)
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
