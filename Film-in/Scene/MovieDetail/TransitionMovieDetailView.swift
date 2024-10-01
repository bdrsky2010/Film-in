//
//  MovieDetailView.swift
//  Film-in
//
//  Created by Minjae Kim on 9/27/24.
//

import SwiftUI
import Kingfisher
import PopupView
import YouTubePlayerKit

struct TransitionMovieDetailView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var viewModel: MovieDetailViewModel
    
    @State private var isFullOverview: Bool
    @State private var isDateSetup: Bool
    @State private var dateSetupType: DateSetupType
    
    @Binding var offset: CGFloat
    @Binding var showDetailView: Bool
    
    var namespace: Namespace.ID
    
    private let movie: HomeMovie.Movie
    private let size: CGSize
    
    init(
        viewModel: MovieDetailViewModel,
        isFullOverview: Bool = false,
        isDateSetup: Bool = false,
        dateSetupType: DateSetupType = .want,
        offset: Binding<CGFloat>,
        showDetailView: Binding<Bool>,
        namespace: Namespace.ID,
        movie: HomeMovie.Movie,
        size: CGSize
    ) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self._isFullOverview = State(wrappedValue: isFullOverview)
        self._isDateSetup = State(wrappedValue: isDateSetup)
        self._dateSetupType = State(wrappedValue: dateSetupType)
        self._offset = offset
        self._showDetailView = showDetailView
        self.namespace = namespace
        self.movie = movie
        self.size = size
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                if !viewModel.output.networkConnect {
                    NotConnectView(viewModel: viewModel)
                } else {
                    HStack {
                        Button {
                            withAnimation(.easeInOut) {
                                showDetailView = false
                            }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .tint(.appText)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.horizontal, 20)
                    
                    ScrollView {
                        LazyVStack {
                            let url = URL(string: ImageURL.tmdb(image: movie.poster).urlString)
                            PosterImage(
                                url: url,
                                size: CGSize(
                                    width: size.width * 1.3,
                                    height: size.height * 1.3),
                                title: movie.title
                            )
                            .matchedGeometryEffect(
                                id: movie.id,
                                in: namespace
                            )
                            
                            VStack {
                                HStack(alignment: .lastTextBaseline) {
                                    Text(viewModel.output.movieDetail.title)
                                        .lineLimit(2)
                                        .font(.ibmPlexMonoSemiBold(size: 26))
                                        .foregroundStyle(.appText)
                                    Spacer()
                                    Image(systemName: "star.fill")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                        .foregroundStyle(.yellow)
                                    Text("\(String(format: "%.1f", viewModel.output.movieDetail.rating))")
                                        .font(.system(size: 26))
                                        .foregroundStyle(.appText)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                
                                HStack(alignment: .lastTextBaseline) {
                                    Text(viewModel.output.movieDetail.releaseDate.replacingOccurrences(of: "-", with: "."))
                                    Text("\(viewModel.output.movieDetail.runtime / 60)h \(viewModel.output.movieDetail.runtime % 60)m")
                                        .padding(.leading, 8)
                                }
                                .font(.ibmPlexMonoSemiBold(size: 16))
                                .foregroundStyle(.appText)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                
                                HStack {
                                    Button {
                                        dateSetupType = .want
                                        isDateSetup.toggle()
                                    } label: {
                                        Text("WANT")
                                            .font(.ibmPlexMonoSemiBold(size: 20))
                                            .frame(maxWidth: .infinity)
                                            .padding(.horizontal, 20)
                                            .padding(.vertical, 8)
                                            .background(Color(uiColor: .app).opacity(0.3))
                                            .foregroundStyle(.app)
                                    }
                                    
                                    Button {
                                        dateSetupType = .watched
                                        isDateSetup.toggle()
                                    } label: {
                                        Text("WATHCED")
                                            .font(.ibmPlexMonoSemiBold(size: 20))
                                            .frame(maxWidth: .infinity)
                                            .padding(.horizontal, 20)
                                            .padding(.vertical, 8)
                                            .background(Color(uiColor: .app).opacity(0.3))
                                            .foregroundStyle(.app)
                                    }
                                }
                            }
                            .frame(height: 150, alignment: .top)
                            
                            InfoHeader(titleKey: "overview")
                                .padding(.top, 4)
                            Text(viewModel.output.movieDetail.overview)
                                .font(.ibmPlexMonoMedium(size: 18))
                                .foregroundStyle(.appText)
                                .lineLimit(isFullOverview ? nil : 4)
                                .multilineTextAlignment(.leading)
                                .padding(4)
                            
                            Button {
                                isFullOverview.toggle()
                            } label: {
                                Image(systemName: isFullOverview ? "chevron.up" : "chevron.down")
                                    .resizable()
                                    .frame(width: 20, height: 12)
                                    .foregroundStyle(.app)
                            }
                            .padding()
                            
                            InfoHeader(titleKey: "castcrew")
                            ScrollView(.horizontal) {
                                LazyHStack(spacing: 12) {
                                    ForEach(viewModel.output.creditInfo, id: \.id) { person in
                                        NavigationLink {
                                            PersonDetailView(
                                                viewModel: PersonDetailViewModel(
                                                    personDetailService: DefaultPersonDetailService(
                                                        tmdbRepository: DefaultTMDBRepository.shared,
                                                        databaseRepository: RealmRepository.shared
                                                    ),
                                                    networkMonitor: NetworkMonitor.shared,
                                                    personId: person._id
                                                )
                                            )
                                        } label: {
                                            VStack {
                                                let url = URL(string: ImageURL.tmdb(image: person.profilePath).urlString)
                                                PosterImage(
                                                    url: url,
                                                    size: CGSize(width: 90, height: 90),
                                                    title: person.name.replacingOccurrences(of: " ", with: "\n")
                                                )
                                                .clipShape(Circle())
                                                .grayscale(colorScheme == .dark ? 1 : 0)
                                                
                                                Text("\(person.role.replacingOccurrences(of: " ", with: "\n"))")
                                                    .font(.ibmPlexMonoRegular(size: 14))
                                                    .foregroundStyle(.appText)
                                                    .frame(width: 90)
                                                Text("\(person.name)")
                                                    .font(.ibmPlexMonoRegular(size: 14))
                                                    .foregroundStyle(.appText)
                                                    .frame(width: 90)
                                            }
                                            .frame(maxHeight: .infinity, alignment: .top)
                                        }
                                    }
                                }
                            }
                            .padding(.vertical, 8)
                            
                            InfoHeader(titleKey: "genre")
                            ScrollView(.horizontal) {
                                LazyHStack(spacing: 12) {
                                    ForEach(viewModel.output.movieDetail.genres, id: \.id) { genre in
                                        Text("\(genre.name)")
                                            .font(.ibmPlexMonoMedium(size: 20))
                                            .foregroundStyle(.app)
                                            .padding(.horizontal)
                                            .padding(.vertical, 4)
                                            .overlay {
                                                Rectangle()
                                                    .fill(Color(uiColor: .app).opacity(0.1))
                                            }
                                    }
                                }
                            }
                            .padding(.vertical, 8)
                            
                            HStack(alignment: .lastTextBaseline) {
                                InfoHeader(titleKey: "simliar")
                                
                                Spacer()
                                
                                NavigationLink {
                                    SeeMoreView(usedTo: .similar(viewModel.movieId))
                                } label: {
                                    Text("more")
                                        .font(.ibmPlexMonoSemiBold(size: 16))
                                        .underline()
                                        .foregroundStyle(.app)
                                }
                            }
                            
                            ScrollView(.horizontal) {
                                LazyHStack(spacing: 12) {
                                    ForEach(viewModel.output.movieSimilars) { similar in
                                        NavigationLink {
                                            MovieDetailView(
                                                movie: .init(
                                                    _id: similar.id,
                                                    title: similar.title,
                                                    poster: similar.poster,
                                                    backdrop: similar.backdrop
                                                ),
                                                size: size,
                                                viewModel: MovieDetailViewModel(
                                                    movieDetailService: DefaultMovieDetailService(
                                                        tmdbRepository: DefaultTMDBRepository.shared,
                                                        databaseRepository: RealmRepository.shared
                                                    ),
                                                    networkMonitor: NetworkMonitor.shared,
                                                    movieId: movie._id
                                                )
                                            )
                                        } label: {
                                            let url = URL(string: ImageURL.tmdb(image: similar.poster).urlString)
                                            PosterImage(
                                                url: url,
                                                size: CGSize(
                                                    width: size.width * 0.5,
                                                    height: size.height * 0.5
                                                ),
                                                title: similar.title
                                            )
                                            .padding(.horizontal, 8)
                                        }
                                    }
                                }
                            }
                            .padding(.vertical, 8)
                            
                            InfoHeader(titleKey: "backdrop")
                            ScrollView(.horizontal) {
                                LazyHStack(spacing: 12) {
                                    ForEach(viewModel.output.movieImages.backdrops) { backdrop in
                                        let url = URL(string: ImageURL.tmdb(image: backdrop.path).urlString)
                                        PosterImage(
                                            url: url,
                                            size: CGSize(
                                                width: size.height * 0.4 * backdrop.ratio,
                                                height: size.height * 0.4
                                            ),
                                            title: ""
                                        )
                                        .padding(.horizontal, 8)
                                    }
                                }
                            }
                            .padding(.vertical, 8)
                            
                            InfoHeader(titleKey: "poster")
                            ScrollView(.horizontal) {
                                LazyHStack(spacing: 12) {
                                    ForEach(viewModel.output.movieImages.posters) { poster in
                                        let url = URL(string: ImageURL.tmdb(image: poster.path).urlString)
                                        PosterImage(
                                            url: url,
                                            size: CGSize(
                                                width: Double(poster.width) * 0.1,
                                                height: Double(poster.height) * 0.1
                                            ),
                                            title: ""
                                        )
                                        .padding(.horizontal, 8)
                                    }
                                }
                            }
                            .padding(.vertical, 8)
                            
                            InfoHeader(titleKey: "video")
                            ScrollView(.horizontal) {
                                LazyHStack(spacing: 12) {
                                    ForEach(viewModel.output.movieVideos) { video in
                                        let youTubePlayer = YouTubePlayer(source: .url(VideoURL.youtube(key: video.key).urlString))
                                        YouTubePlayerView(youTubePlayer) { state in
                                            switch state {
                                            case .idle:
                                                ProgressView()
                                            case .ready:
                                                EmptyView()
                                            case .error(_):
                                                Text(verbatim: "YouTube player couldn't be loaded")
                                            }
                                        }
                                        .frame(
                                            width: size.height * 0.4 * 1.778,
                                            height: size.height * 0.4
                                        )
                                        .padding(.horizontal, 8)
                                    }
                                }
                            }
                        }
                        .padding()
                        .modifier(OffsetModifier(offset: $offset))
                    }
                    .scrollIndicators(.hidden)
                }
            }
            .task {
                viewModel.action(.viewOnTask)
            }
            .coordinateSpace(name: "SCROLL")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.background)
            .statusBar(hidden: true)
            .toolbar(.hidden, for: .tabBar)
            .toolbar(.hidden, for: .navigationBar)
            .valueChanged(value: offset) { newValue in
                if newValue > 120 {
                    withAnimation(.easeInOut) {
                        showDetailView = false
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        showDetailView = false
                    }
                }
            }
            .sheet(isPresented: $isDateSetup){
                DateSetupView(
                    viewModel: DateSetupViewModel(
                        dateSetupService: DefaultDateSetupService(
                            localNotificationManager: DefaultLocalNotificationManager.shared,
                            databaseRepository: RealmRepository.shared
                        ),
                        movie: (movie._id, movie.title, movie.backdrop, movie.poster),
                        type: dateSetupType
                    ),
                    isPresented: $isDateSetup
                )
            }
            .valueChanged(value: dateSetupType) { newValue in
                
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
            //        .sheet(isPresented: .constant(true)) {
            //            MovieInfoView(
            //                viewModel: MovieInfoViewModel(
            //                    movieInfoService: DefaultMovieInfoService(
            //                        tmdbRepository: DefaultTMDBRepository.shared,
            //                        databaseRepository: RealmRepository.shared
            //                    ),
            //                    networkMonitor: NetworkMonitor.shared,
            //                    movieId: movie._id
            //                ),
            //                posterSize: size
            //            )
            //            .presentationDetents([.height(160), .large])
            //            .presentationBackgroundInteraction(.enabled(upThrough: .height(160)))
            //            .presentationCornerRadius(0)
            //            .presentationDragIndicator(.visible)
            //            .interactiveDismissDisabled()
            //        }
        }
    }
}

fileprivate struct NotConnectView: View {
    @ObservedObject var viewModel: MovieDetailViewModel
    
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
//    @Namespace var namespace
//    return TransitionMovieDetailView(offset: .constant(0), showDetailView: .constant(true), namespace: namespace, movie: .init(_id: 1022789, title: "인사이드 아웃 2", poster: "/x2BHx02jMbvpKjMvbf8XxJkYwHJ.jpg"), size: CGSize(width: 275.09999999999997, height: 412.65))
//}
