//
//  SearchView.swift
//  Film-in
//
//  Created by Minjae Kim on 12/2/24.
//

import SwiftUI

enum FocusField {
    case cover, search
}

struct SearchView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @EnvironmentObject var coordinator: Coordinator
    
    @StateObject private var viewModel: SearchViewModel
    
    @FocusState private var focusedField: FocusField?
    
    @State private var cellSize: CGSize = .zero
    @State private var posterSize: CGSize = .zero
    @State private var isShowSearch = false
    @State private var searchQuery = ""
    
    @Namespace private var namespace
    
    init(
        viewModel: SearchViewModel
    ) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
        
    var body: some View {
        NavigationStack {
            if !viewModel.output.networkConnect {
                UnnetworkedView(refreshAction: viewModel.action(.refresh))
            } else {
                contentSection()
            }
        }
        .task { viewModel.action(.viewOnTask) }
        .popupAlert(
            isPresented: Binding(
                get: { viewModel.output.isShowAlert },
                set: { _ in viewModel.action(.onDismissAlert) }
            ),
            contentModel: .init(
                systemImage: R.AssetImage.wifi,
                phrase: R.Phrase.apiRequestError,
                normal: R.Phrase.refresh
            ),
            heightType: .middle
        ) {
            viewModel.action(.refresh)
        }
    }
}

extension SearchView {
    @ViewBuilder
    private func contentSection() -> some View {
        VStack {
            if isShowSearch {
                SearchResultView(
                    viewModel: coordinator.diContainer.makeSearchResultViewModel(),
                    isShowSearch: $isShowSearch,
                    focusedField: $focusedField,
                    namespace: namespace
                )
            } else {
                VStack {
                    textFieldSection()
                    trendingContentSection()
                }
            }
        }
        .valueChanged(value: focusedField) { _ in
            if focusedField == .cover {
                withAnimation {
                    isShowSearch = true
                    focusedField = .search
                }
            }
        }
    }
    
    @ViewBuilder
    private func textFieldSection() -> some View {
        HStack {
            TextField(R.Phrase.searchPlaceholder, text: $searchQuery)
                .focused($focusedField, equals: .cover)
                .padding()
                .font(.ibmPlexMonoSemiBold(size: 16))
            
            if !searchQuery.isEmpty {
                Button {
                    searchQuery = ""
                } label: {
                    Image(systemName: R.AssetImage.xmark)
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundStyle(.app)
                        .padding(.trailing)
                }
            }
        }
        .overlay {
            Rectangle()
                .stroke(lineWidth: 3)
                .matchedGeometryEffect(id: "TextField", in: namespace)
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private func trendingContentSection() -> some View {
        GeometryReader { proxy in
            ScrollView(.vertical) {
                ForEach(SearchType.allCases, id: \.self) { tab in
                    VStack {
                        HStack {
                            Text(verbatim: tab.description)
                                .font(.ibmPlexMonoSemiBold(size: 20))
                                .bold()
                                .foregroundStyle(.appText)
                                .padding(.bottom, 4)
                                .matchedGeometryEffect(id: "\(tab.description)", in: namespace)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: 8) {
                                switch tab {
                                case .movie:
                                    trendingMovieSection()
                                case .person:
                                    popularPeopleSection()
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.bottom)
                }
                .background(.background)
            }
            .refreshable {
                viewModel.action(.refresh)
            }
            .task {
                if cellSize == .zero {
                    cellSize = CGSize(
                        width: (proxy.size.width - (8 * 2)) / 3,
                        height: (proxy.size.width - (8 * 2)) / 3 * 1.5
                    )
                }
                
                if posterSize == .zero {
                    posterSize = CGSize(width: proxy.size.width * 0.7, height: proxy.size.width * 0.7 * 1.5)
                }
            }
        }
    }
    
    @ViewBuilder
    private func trendingMovieSection() -> some View {
        ForEach(viewModel.output.trendingMovie, id: \.id) { movie in
            posterButton(movie: movie, size: (poster: posterSize, cell: cellSize))
        }
    }
    
    @ViewBuilder
    private func popularPeopleSection() -> some View {
        ForEach(viewModel.output.popularPeople, id: \.id) { person in
            personButton(person: person, size: CGSize(width: 90, height: 90))
        }
    }
}

extension SearchView {
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

extension SearchView {
    @ViewBuilder
    private func personButton(person: PopularPerson, size: CGSize) -> some View {
        Button {
            personTapped(person: person)
        } label: {
            personLabel(person: person, size: size)
        }
    }
    
    private func personTapped(person: PopularPerson) {
        coordinator.push(.personDetail(person._id))
    }
    
    @ViewBuilder
    private func personLabel(person: PopularPerson, size: CGSize) -> some View {
        VStack {
            let url = URL(string: ImageURL.tmdb(image: person.profilePath).urlString)
            PosterImage(
                url: url,
                size: size,
                title: person.name.replacingOccurrences(of: " ", with: "\n"),
                isDownsampling: true
            )
            .clipShape(.circle)
            .grayscale(self.colorScheme == .dark ? 1 : 0)
            
            Text(verbatim: "\(person.name)")
                .font(.ibmPlexMonoRegular(size: 14))
                .foregroundStyle(.appText)
                .frame(width: 90)
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .padding(.horizontal, 4)
    }
}
