//
//  MovieListView.swift
//  Film-in
//
//  Created by Minjae Kim on 9/29/24.
//

import SwiftUI

struct MultiListView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @EnvironmentObject var diContainer: DefaultDIContainer
    
    @StateObject private var viewModel: MultiListViewModel
    
    @State private var cellSize: CGSize = .zero
    @State private var posterSize: CGSize = .zero
    
    @Binding var isShowAlert: Bool
    @Binding var isRefresh: Bool
    
    private let gridItemLayout = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    init(
        viewModel: MultiListViewModel,
        isShowAlert: Binding<Bool>,
        isRefresh: Binding<Bool>
    ) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self._isShowAlert = isShowAlert
        self._isRefresh = isRefresh
    }
    
    var body: some View {
        GeometryReader { proxy in
            if !viewModel.output.networkConnect {
                UnnetworkedView(refreshAction: viewModel.action(.refresh))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.output.isFirstFetch {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    contentSection()
                }
                .task {
                    cellSize = CGSize(width: (proxy.size.width - (8 * 2)) / 3, height: (proxy.size.width - (8 * 2)) / 3 * 1.5)
                    posterSize = CGSize(width: proxy.size.width * 0.7, height: proxy.size.width * 0.7 * 1.5)
                }
            }
        }
        .navigationTitle(viewModel.usedTo.title)
        .ignoresSafeArea(.all, edges: .bottom)
        .toolbar(.hidden, for: .tabBar)
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
    private func contentSection() -> some View {
        switch viewModel.usedTo {
        case .searchPerson:
            peopleListSection()
        default:
            movieListSection()
        }
        
        if viewModel.output.isPagination {
            ProgressView()
        }
    }
    
    @ViewBuilder
    private func movieListSection() -> some View {
        LazyVGrid(columns: gridItemLayout) {
            ForEach(viewModel.output.movies.movies, id: \.id) { movie in
                NavigationLink {
                    LazyView(
                        MovieDetailView(
                            viewModel: diContainer.makeMovieDetailViewModel(movieID: movie._id),
                            movie: movie,
                            size: posterSize
                        )
                    )
                } label: {
                    let url = URL(string: ImageURL.tmdb(image: movie.poster).urlString)
                    PosterImage(
                        url: url,
                        size: cellSize,
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
                    LazyView(
                        PersonDetailView(
                            viewModel: diContainer.makePersonDetailViewModel(personID: person._id)
                        )
                    )
                } label: {
                    VStack {
                        let url = URL(string: ImageURL.tmdb(image: person.profile).urlString)
                        PosterImage(
                            url: url,
                            size: CGSize(width: 90, height: 90),
                            title: person.name,
                            isDownsampling: true
                        )
                        .clipShape(Circle())
                        .grayscale(colorScheme == .dark ? 1 : 0)
                        
                        Text(verbatim: "\(person.name)")
                            .font(.ibmPlexMonoRegular(size: 14))
                            .foregroundStyle(.appText)
                            .frame(width: 90)
                    }
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
