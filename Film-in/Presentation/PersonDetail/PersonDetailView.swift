//
//  PersonDetailView.swift
//  Film-in
//
//  Created by Minjae Kim on 9/30/24.
//

import SwiftUI

struct PersonDetailView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @EnvironmentObject var diContainer: DefaultDIContainer
    
    @StateObject private var viewModel: PersonDetailViewModel
    
    @State private var posterSize: CGSize = .zero
    
    private let gridItemLayout = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    init(
        viewModel: PersonDetailViewModel
    ) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let gridWidth = (proxy.size.width - (8 * 2 + 40)) / 3
            let gridHeight = (proxy.size.width - (8 * 2 + 40)) / 3 * 1.5
            
            VStack {
                if !viewModel.output.networkConnect {
                    UnnetworkedView(refreshAction: viewModel.action(.refresh))
                } else {
                    infoSection(width: width, gridSize: CGSize(width: gridWidth, height: gridHeight))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .task {
                posterSize = CGSize(
                    width: proxy.size.width * 0.7,
                    height: proxy.size.width * 0.7 * 1.5
                )
            }
        }
        .ignoresSafeArea(.all, edges: .top)
        .toolbar(.hidden, for: .tabBar)
        .task { viewModel.action(.viewOnTask) }
        .popupAlert(
            isPresented: Binding(
                get: { viewModel.output.isShowAlert },
                set: { _ in viewModel.action(.onDismissAlert) }
            ),
            contentModel: .init(
                systemImage: R.AssetImage.wifi,
                phrase: "apiRequestError",
                normal: "refresh"
            ),
            heightType: .middle
        ) {
            viewModel.action(.refresh)
        }
    }
    
    @ViewBuilder
    private func infoSection(width: CGFloat, gridSize: CGSize) -> some View {
        ScrollView {
            VStack {
                mainImageSection(width: width)
                
                LazyVStack {
                    keyInfoSection()
                    filmographySection(size: gridSize)
                }
                .padding()
            }
        }
    }
    
    @ViewBuilder
    private func mainImageSection(width: CGFloat) -> some View {
        let url = URL(string: ImageURL.tmdb(image: viewModel.output.personDetail.profilePath).urlString)
        PosterImage(
            url: url,
            size: CGSize(width: width, height: width * 1.5),
            title: viewModel.output.personDetail.name,
            isDownsampling: false
        )
        .grayscale(colorScheme == .dark ? 1 : 0)
    }
    
    @ViewBuilder
    private func keyInfoSection() -> some View {
        Text(verbatim: viewModel.output.personDetail.name)
            .font(.ibmPlexMonoSemiBold(size: 30))
            .foregroundStyle(.appText)
            .frame(maxWidth: .infinity, alignment: .leading)
        
        VStack {
            Text(verbatim: viewModel.output.personDetail.birthday)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(verbatim: viewModel.output.personDetail.placeOfBirth)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .font(.ibmPlexMonoMedium(size: 18))
        .foregroundStyle(.appText)
    }
    
    @ViewBuilder
    private func filmographySection(size: CGSize) -> some View {
        InfoHeader(titleKey: "filmography")
            .padding(.vertical)
        LazyVGrid(columns: gridItemLayout) {
            ForEach(viewModel.output.personMovie.movies, id: \.id) { movie in
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
                        size: size,
                        title: movie.title,
                        isDownsampling: true
                    )
                }
            }
        }
    }
}

fileprivate struct InfoHeader: View {
    let titleKey: LocalizedStringKey
    
    var body: some View {
        Text(titleKey)
            .font(.ibmPlexMonoSemiBold(size: 24))
            .foregroundStyle(.appText)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
