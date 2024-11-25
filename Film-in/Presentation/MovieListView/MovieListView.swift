//
//  MovieListView.swift
//  Film-in
//
//  Created by Minjae Kim on 9/29/24.
//

import SwiftUI

struct MovieListView: View {
    private var gridItemLayout = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    @StateObject private var viewModel: MovieListViewModel
    @State private var posterSize: CGSize = .zero
    @State private var movie: MovieData?
    
    @Binding var isShowAlert: Bool
    @Binding var isRefresh: Bool
    
    init(
        viewModel: MovieListViewModel,
        isShowAlert: Binding<Bool>,
        isRefresh: Binding<Bool>
    ) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self._isShowAlert = isShowAlert
        self._isRefresh = isRefresh
    }
    
    var body: some View {
        GeometryReader { proxy in
            let width = (proxy.size.width - (8 * 2)) / 3
            let height = (proxy.size.width - (8 * 2)) / 3 * 1.5
            ScrollView {
                if !viewModel.output.networkConnect {
                    UnnetworkedView(refreshAction: viewModel.action(.refresh))
                    .frame(maxWidth: proxy.size.width, alignment: .center)
                } else {
                    contentSection(width: width, height: height)
                }
            }
            .task {
                posterSize = CGSize(width: proxy.size.width * 0.7, height: proxy.size.width * 0.7 * 1.5)
            }
        }
        .task {
            viewModel.action(.viewOnTask)
        }
        .valueChanged(value: viewModel.output.isShowAlert) { newValue in
            isShowAlert = newValue
        }
        .valueChanged(value: isRefresh) { newValue in
            if isRefresh {
                viewModel.action(.refresh)
                isRefresh = false
            }
        }
    }
    
    @ViewBuilder
    private func contentSection(width: CGFloat, height: CGFloat) -> some View {
        movieListSection(width: width, height: height)
        
        if viewModel.output.isPagination {
            ProgressView()
        }
    }
    
    @ViewBuilder
    private func movieListSection(width: CGFloat, height: CGFloat) -> some View {
        LazyVGrid(columns: gridItemLayout, spacing: 8) {
            ForEach(viewModel.output.movies.movies, id: \.id) { movie in
                NavigationLink {
                    LazyView(MovieDetailFactory.makeView(movie: movie, posterSize: posterSize))
                } label: {
                    let url = URL(string: ImageURL.tmdb(image: movie.poster).urlString)
                    PosterImage(
                        url: url,
                        size: CGSize(width: width, height: height),
                        title: movie.title
                    )
                    .padding(.bottom, 4)
                    .padding(.horizontal, 8)
                }
                .task {
                    if let last = viewModel.output.movies.movies.last,
                       last.id == movie.id {
                        viewModel.action(.lastElement)
                    }
                }
            }
        }
    }
}
