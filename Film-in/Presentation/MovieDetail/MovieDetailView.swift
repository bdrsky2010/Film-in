//
//  MovieDetailView.swift
//  Film-in
//
//  Created by Minjae Kim on 9/30/24.
//

import SwiftUI
import Kingfisher
import YouTubePlayerKit

struct MovieDetailView: View {
    private let movie: MovieData
    private let size: CGSize
    
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject private var viewModel: MovieDetailViewModel
    
    @State private var isFullOverview: Bool
    @State private var isDateSetup: Bool
    @State private var dateSetupType: DateSetupType
    
    init(
        movie: MovieData,
        size: CGSize,
        viewModel: MovieDetailViewModel,
        isFullOverview: Bool = false,
        isDateSetup: Bool = false,
        dateSetupType: DateSetupType = .want
    ) {
        self.movie = movie
        self.size = size
        self._viewModel = StateObject(wrappedValue: viewModel)
        self._isFullOverview = State(wrappedValue: isFullOverview)
        self._isDateSetup = State(wrappedValue: isDateSetup)
        self._dateSetupType = State(wrappedValue: dateSetupType)
    }
    
    var body: some View {
        VStack {
            if !viewModel.output.networkConnect {
                UnnetworkedView(refreshAction: viewModel.action(.refresh))
            } else {
                infoSection()
            }
        }
        .task {
            viewModel.action(.viewOnTask)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(.background)
        .toolbar(.hidden, for: .tabBar)
        .valueChanged(value: dateSetupType) { newValue in
            // dateSetupType의 변화를 확인하지 않으면 속성 값이 바뀌지 않음.
        }
        .sheet(isPresented: $isDateSetup){
            dateSetupSheet()
        }
        .apiRequestErrorAlert(isPresented: $viewModel.output.isShowAlert) {
            viewModel.action(.refresh)
        }
    }
    
    @ViewBuilder
    private func infoSection() -> some View {
        ScrollView {
            LazyVStack {
                mainPosterSection()
                
                VStack {
                    keyInfoSection()
                    wantWatchedSection()
                }
                .frame(height: 150, alignment: .top)
                
                overviewSection()
                castcrewSection()
                genreSection()
                similarSection()
                backdropSection()
                posterSection()
                videoSection()
            }
        }
        .scrollIndicators(.hidden)
    }
    
    @ViewBuilder
    private func mainPosterSection() -> some View {
        let url = URL(string: ImageURL.tmdb(image: movie.poster).urlString)
        PosterImage(
            url: url,
            size: CGSize(
                width: size.width,
                height: size.height),
            title: movie.title,
            isDownsampling: true
        )
    }
    
    @ViewBuilder
    private func keyInfoSection() -> some View {
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
    }
    
    @ViewBuilder
    private func wantWatchedSection() -> some View {
        HStack {
            Button {
                dateSetupType = .want
                isDateSetup.toggle()
            } label: {
                Text("WANT")
                    .appButtonText()
            }
            
            Button {
                dateSetupType = .watched
                isDateSetup.toggle()
            } label: {
                Text("WATHCED")
                    .appButtonText()
            }
        }
    }
    
    @ViewBuilder
    private func overviewSection() -> some View {
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
    }
    
    @ViewBuilder
    private func castcrewSection() -> some View {
        InfoHeader(titleKey: "castcrew")
        ScrollView(.horizontal) {
            LazyHStack(spacing: 12) {
                ForEach(viewModel.output.creditInfo, id: \.id) { person in
                    NavigationLink {
                        LazyView(PersonDetailFactory.makeView(personId: person._id))
                    } label: {
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
    }
    
    @ViewBuilder
    private func genreSection() -> some View {
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
    }
    
    @ViewBuilder
    private func similarSection() -> some View {
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
                        LazyView(
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
                                    movieId: similar.id
                                )
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
                            title: similar.title,
                            isDownsampling: true
                        )
                        .padding(.horizontal, 8)
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    @ViewBuilder
    private func backdropSection() -> some View {
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
                        title: "",
                        isDownsampling: true
                    )
                    .padding(.horizontal, 8)
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    @ViewBuilder
    private func posterSection() -> some View {
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
                        title: "",
                        isDownsampling: true
                    )
                    .padding(.horizontal, 8)
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    @ViewBuilder
    private func videoSection() -> some View {
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
    
    @ViewBuilder
    private func dateSetupSheet() -> some View {
        DateSetupFactory.makeView(movie: movie, type: dateSetupType, isPresented: $isDateSetup)
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
//    MovieDetailView(
//        movie: .init(
//            _id: 1022789,
//            title: "인사이드 아웃 2",
//            poster: "/x2BHx02jMbvpKjMvbf8XxJkYwHJ.jpg",
//            backdrop: ""
//        ),
//        size: CGSize(width: 275.09999999999997, height: 412.65),
//        viewModel: MovieDetailViewModel(
//            movieDetailService: DefaultMovieDetailService(
//                tmdbRepository: DefaultTMDBRepository.shared,
//                databaseRepository: RealmRepository.shared
//            ),
//            networkMonitor: NetworkMonitor.shared,
//            movieId: 1022789
//        )
//    )
//}
