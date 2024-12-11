//
//  MovieListView.swift
//  Film-in
//
//  Created by Minjae Kim on 9/29/24.
//

import SwiftUI

struct MovieListView: View {
    @StateObject private var viewModel: MovieListViewModel
    
    @State private var posterSize: CGSize = .zero
    
    @Binding var isShowAlert: Bool
    @Binding var isRefresh: Bool
    
    private let gridItemLayout = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
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
        switch viewModel.usedTo {
        case .searchPerson:
            peopleListSection()
        default:
            movieListSection(width: width, height: height)
        }
        
        if viewModel.output.isPagination {
            ProgressView()
        }
    }
    
    @ViewBuilder
    private func movieListSection(width: CGFloat, height: CGFloat) -> some View {
        LazyVGrid(columns: gridItemLayout) {
            ForEach(viewModel.output.movies.movies, id: \.id) { movie in
                NavigationLink {
                    LazyView(MovieDetailFactory.makeView(movie: movie, posterSize: posterSize))
                } label: {
                    let url = URL(string: ImageURL.tmdb(image: movie.poster).urlString)
                    PosterImage(
                        url: url,
                        size: CGSize(width: width, height: height),
                        title: movie.title,
                        isDownsampling: true
                    )
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
    
    @ViewBuilder
    private func peopleListSection() -> some View {
        LazyVGrid(columns: gridItemLayout) {
            ForEach(viewModel.output.people.people, id: \.id) { person in
                NavigationLink {
                    LazyView(PersonDetailFactory.makeView(personId: person._id))
                } label: {
                    let url = URL(string: ImageURL.tmdb(image: person.profile).urlString)
                    PosterImage(
                        url: url,
                        size: CGSize(width: 90, height: 90),
                        title: person.name,
                        isDownsampling: true
                    )
                }
                .task {
                    if let last = viewModel.output.people.people.last,
                       last.id == person.id {
                        viewModel.action(.lastElement)
                    }
                }
            }
        }
    }
}
