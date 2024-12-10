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
        .task {
            viewModel.action(.viewOnTask)
        }
    }
    
    @ViewBuilder
    private func contentSection() -> some View {
        ZStack {
            VStack {
                textFieldSection()
                trendingContentSection()
            }
            
            if isShowSearch {
                SearchResultView(
                    viewModel: SearchResultViewModel(
                        networkMonitor: NetworkMonitor.shared, searchResultService: DefaultSearchResultService(tmdbRepository: DefaultTMDBRepository.shared)
                    ),
                    isShowSearch: $isShowSearch,
                    focusedField: $focusedField,
                    namespace: namespace
                )
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
        .popupAlert(
            isPresented: $viewModel.output.isShowAlert,
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
    
    @ViewBuilder
    private func textFieldSection() -> some View {
        HStack {
            TextField("searchPlaceholder", text: $searchQuery)
                .focused($focusedField, equals: .cover)
                .padding()
                .font(.ibmPlexMonoSemiBold(size: 16))
            
            if !searchQuery.isEmpty {
                Button {
                    searchQuery = ""
                } label: {
                    Image(systemName: "xmark.app.fill")
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
            let url = URL(string: ImageURL.tmdb(image: movie.poster).urlString)
            PosterImage(
                url: url,
                size: cellSize,
                title: movie.title,
                isDownsampling: true
            )
        }
    }
    
    @ViewBuilder
    private func popularPeopleSection() -> some View {
        ForEach(viewModel.output.popularPeople, id: \.id) { person in
            VStack {
                let url = URL(string: ImageURL.tmdb(image: person.profilePath).urlString)
                PosterImage(
                    url: url,
                    size: CGSize(width: 90, height: 90),
                    title: person.name.replacingOccurrences(of: " ", with: "\n"),
                    isDownsampling: true
                )
                .clipShape(Circle())
                .grayscale(colorScheme == .dark ? 1 : 0)
                
                Text("\(person.name)")
                    .font(.ibmPlexMonoRegular(size: 14))
                    .foregroundStyle(.appText)
                    .frame(width: 90)
            }
            .padding(.horizontal, 4)
        }
    }
}

#Preview {
    SearchView(
        viewModel: SearchViewModel(
            searchSerivce: DefaultSearchService(
                tmdbRepository: DefaultTMDBRepository.shared
            ),
            networkMonitor: NetworkMonitor.shared)
    )
}
