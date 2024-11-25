//
//  PersonDetailView.swift
//  Film-in
//
//  Created by Minjae Kim on 9/30/24.
//

import SwiftUI

struct PersonDetailView: View {
    private var gridItemLayout = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var viewModel: PersonDetailViewModel
    @State private var posterSize: CGSize = .zero
    
    init(viewModel: PersonDetailViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let gridWidth = (proxy.size.width - (8 * 2 + 40)) / 3
            let gridHeight = (proxy.size.width - (8 * 2 + 40)) / 3 * 1.5
            
            ScrollView {
                if !viewModel.output.networkConnect {
                    UnnetworkedView {
                        viewModel.action(.refresh)
                    }
                    .frame(width: width)
                    .padding(.top, 80)
                } else {
                    infoSection(width: width, gridSize: CGSize(width: gridWidth, height: gridHeight))
                }
            }
            .task {
                posterSize = CGSize(
                    width: proxy.size.width * 0.7,
                    height: proxy.size.width * 0.7 * 1.5
                )
            }
        }
        .ignoresSafeArea()
        .task {
            viewModel.action(.viewOnTask)
        }
        .apiRequestErrorAlert(isPresented: $viewModel.output.isShowAlert) {
            viewModel.action(.refresh)
        }
    }
    
    @ViewBuilder
    private func infoSection(width: CGFloat, gridSize: CGSize) -> some View {
        VStack {
            mainImageSection(width: width)
            
            LazyVStack {
                keyInfoSection()
                filmographySection(size: gridSize)
            }
            .padding()
        }
    }
    
    @ViewBuilder
    private func mainImageSection(width: CGFloat) -> some View {
        let url = URL(string: ImageURL.tmdb(image: viewModel.output.personDetail.profilePath).urlString)
        PosterImage(
            url: url,
            size: CGSize(width: width, height: width * 1.5),
            title: viewModel.output.personDetail.name
        )
        .grayscale(colorScheme == .dark ? 1 : 0)
    }
    
    @ViewBuilder
    private func keyInfoSection() -> some View {
        Text(viewModel.output.personDetail.name)
            .font(.ibmPlexMonoSemiBold(size: 30))
            .foregroundStyle(.appText)
            .frame(maxWidth: .infinity, alignment: .leading)
        
        VStack {
            Text(viewModel.output.personDetail.birthday)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(viewModel.output.personDetail.placeOfBirth)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .font(.ibmPlexMonoMedium(size: 18))
        .foregroundStyle(.appText)
    }
    
    @ViewBuilder
    private func filmographySection(size: CGSize) -> some View {
        InfoHeader(titleKey: "filmography")
            .padding(.vertical)
        LazyVGrid(columns: gridItemLayout, spacing: 8) {
            ForEach(viewModel.output.personMovie.movies, id: \.id) { movie in
                NavigationLink {
                    LazyView(MovieDetailFactory.makeView(movie: movie, posterSize: posterSize))
                } label: {
                    let url = URL(string: ImageURL.tmdb(image: movie.poster).urlString)
                    PosterImage(
                        url: url,
                        size: size,
                        title: movie.title
                    )
                    .padding(.bottom, 4)
                    .padding(.horizontal, 8)
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

//#Preview {
//    PersonDetailView(
//        viewModel: PersonDetailViewModel(
//            personDetailService: DefaultPersonDetailService(
//                tmdbRepository: DefaultTMDBRepository.shared,
//                databaseRepository: RealmRepository.shared
//            ),
//            networkMonitor: NetworkMonitor.shared,
//            personId: 74568)
//    )
//}
