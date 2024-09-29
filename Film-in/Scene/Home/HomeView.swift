//
//  HomeView.swift
//  Film-in
//
//  Created by Minjae Kim on 9/26/24.
//

import SwiftUI
import PopupView

struct Card: Hashable, Identifiable {
    let id = UUID()
    var title: String
}

struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel
    @Namespace var namespace
    @State private var index = 0
    @State private var items = [Card(title: "1"), Card(title: "2"), Card(title: "3"), Card(title: "4")]
    @State private var showDetailView = false
    @State private var movie: HomeMovie.Movie?
    @State private var cardSize: CGSize = .zero
    @State private var offset: CGFloat = 0
    
    init(viewModel: HomeViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // poster size 1 x 1.5
    var body: some View {
        if !viewModel.output.networkConnect {
            NotConnectView(viewModel: viewModel)
        } else {
            GeometryReader { proxy in
                VStack {
                    Text("Film-in")
                        .font(.ibmPlexMonoSemiBold(size: 50))
                        .foregroundStyle(.app)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .frame(height: 50)
                    
                    ScrollView {
                        SnapCarousel(spacing: 28, trailingSpace: 120, index: $index, items: viewModel.output.trendingMovies.movies) { movie in
                            
                            let url = URL(string: ImageURL.tmdb(image: movie.poster).urlString)
                            PosterImage(url: url, size: cardSize, title: movie.title)
                                .matchedGeometryEffect(id: movie.id, in: namespace)
                                .onTapGesture {
                                    self.movie = movie
                                    withAnimation(.easeInOut) {
                                        showDetailView = true
                                    }
                                }
                        }
                        .frame(height: cardSize.height)
                        .padding(.bottom, 20)
                        
                        ListHeader(title: "nowPlaying")
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack {
                                ForEach(viewModel.output.nowPlayingMovies.movies, id: \.id) { movie in
                                    let url = URL(string: ImageURL.tmdb(image: movie.poster).urlString)
                                    PosterImage(url: url, size: CGSize(width: cardSize.width * 0.5, height: cardSize.height * 0.5), title: movie.title)
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
                        
                        
                        ListHeader(title: "upcoming")
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack {
                                ForEach(viewModel.output.upcomingMovies.movies, id: \.id) { movie in
                                    let url = URL(string: ImageURL.tmdb(image: movie.poster).urlString)
                                    PosterImage(url: url, size: CGSize(width: cardSize.width * 0.5, height: cardSize.height * 0.5), title: movie.title)
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
                        
                        
                        ListHeader(title: "recommend")
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack {
                                ForEach(viewModel.output.recommendMovies.movies, id: \.id) { movie in
                                    let url = URL(string: ImageURL.tmdb(image: movie.poster).urlString)
                                    PosterImage(url: url, size: CGSize(width: cardSize.width * 0.5, height: cardSize.height * 0.5), title: movie.title)
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
                    }
                }
                .task {
                    cardSize = CGSize(width: proxy.size.width * 0.7, height: proxy.size.width * 0.7 * 1.5)
                }
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .overlay {
                if let movie, showDetailView {
                    MovieDetailView(
                        offset: $offset,
                        showDetailView: $showDetailView,
                        namespace: namespace,
                        movie: movie,
                        size: cardSize
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

struct ListHeader: View {
    enum ListType {
        case nowPlaying
        case upcoming
        case recommend
    }
    
    let title: LocalizedStringKey
    
    var body: some View {
        HStack(alignment: .lastTextBaseline) {
            Text(title)
                .font(.ibmPlexMonoSemiBold(size: 24))
                .foregroundStyle(.appText)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
            Button {
                withAnimation {
                    
                }
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

#Preview {
    MainTabView()
}
