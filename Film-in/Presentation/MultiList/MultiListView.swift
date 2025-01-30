//
//  MovieListView.swift
//  Film-in
//
//  Created by Minjae Kim on 9/29/24.
//

import SwiftUI

struct MultiListView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @EnvironmentObject var coordinator: Coordinator
    
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
                posterButton(movie: movie, size: (poster: posterSize, cell: cellSize))
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
                personButton(person: person, size: CGSize(width: 90, height: 90))
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

extension MultiListView {
    @ViewBuilder
    private func posterButton(movie: MovieData, size: (poster: CGSize, cell: CGSize)) -> some View {
        Button {
            posterTapped(movie: movie, size: size.poster)
        } label: {
            posterLabel(movie: movie, size: size.cell)
        }
    }
    
    private func posterTapped(movie: MovieData, size: CGSize) {
        coordinator.push(.movieDetail(movie, size))
    }
    
    @ViewBuilder
    private func posterLabel(movie: MovieData, size: CGSize) -> some View {
        let url = URL(string: ImageURL.tmdb(image: movie.poster).urlString)
        PosterImage(
            url: url,
            size: size,
            title: movie.title,
            isDownsampling: true
        )
    }
}

extension MultiListView {
    @ViewBuilder
    private func personButton(person: PersonData, size: CGSize) -> some View {
        Button {
            coordinator.push(.personDetail(person._id))
        } label: {
            
        }
    }
    
    private func personTapped(person: PersonData) {
        coordinator.push(.personDetail(person._id))
    }
    
    @ViewBuilder
    private func personLabel(person: PersonData, size: CGSize) -> some View {
        VStack {
            let url = URL(string: ImageURL.tmdb(image: person.profile).urlString)
            PosterImage(
                url: url,
                size: size,
                title: person.name,
                isDownsampling: true
            )
            .clipShape(.circle)
            .grayscale(colorScheme == .dark ? 1 : 0)
            
            Text(verbatim: "\(person.name)")
                .font(.ibmPlexMonoRegular(size: 14))
                .foregroundStyle(.appText)
                .frame(width: 90)
        }
    }
}
