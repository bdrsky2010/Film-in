//
//  PersonDetailView.swift
//  Film-in
//
//  Created by Minjae Kim on 9/30/24.
//

import SwiftUI
import PopupView

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
                    NotConnectView(viewModel: viewModel)
                        .frame(width: width)
                        .padding(.top, 80)
                } else {
                    VStack {
                        let url = URL(string: ImageURL.tmdb(image: viewModel.output.personDetail.profilePath).urlString)
                        PosterImage(
                            url: url,
                            size: CGSize(width: width, height: width * 1.5),
                            title: viewModel.output.personDetail.name
                        )
                        .grayscale(colorScheme == .dark ? 1 : 0)
                        
                        LazyVStack {
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
                            
                            InfoHeader(titleKey: "filmography")
                                .padding(.vertical)
                            LazyVGrid(columns: gridItemLayout, spacing: 8) {
                                ForEach(viewModel.output.personMovie.movies, id: \.id) { movie in
                                    NavigationLink {
                                        LazyView(
                                            MovieDetailView(
                                                movie: .init(_id: movie.id, title: movie.title, poster: movie.poster, backdrop: movie.backdrop),
                                                size: posterSize,
                                                viewModel: MovieDetailViewModel(
                                                    movieDetailService: DefaultMovieDetailService(
                                                        tmdbRepository: DefaultTMDBRepository.shared,
                                                        databaseRepository: RealmRepository.shared
                                                    ),
                                                    networkMonitor: NetworkMonitor.shared,
                                                    movieId: movie.id
                                                )
                                            )
                                        )
                                    } label: {
                                        let url = URL(string: ImageURL.tmdb(image: movie.poster).urlString)
                                        PosterImage(
                                            url: url,
                                            size: CGSize(width: gridWidth, height: gridHeight),
                                            title: movie.title
                                        )
                                        .padding(.bottom, 4)
                                        .padding(.horizontal, 8)
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                    
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
        .popup(isPresented: $viewModel.output.isShowAlert) {
            VStack {
                Text("apiRequestError")
                    .font(.ibmPlexMonoSemiBold(size: 20))
                    .padding(.top)
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

fileprivate struct InfoHeader: View {
    let titleKey: LocalizedStringKey
    
    var body: some View {
        Text(titleKey)
            .font(.ibmPlexMonoSemiBold(size: 24))
            .foregroundStyle(.appText)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

fileprivate struct NotConnectView: View {
    @ObservedObject var viewModel: PersonDetailViewModel
    
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
