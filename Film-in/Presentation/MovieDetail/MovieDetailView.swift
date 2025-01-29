//
//  MovieDetailView.swift
//  Film-in
//
//  Created by Minjae Kim on 9/30/24.
//

import SwiftUI
import YouTubePlayerKit

struct MovieDetailView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var coordinator: Coordinator
    
    @StateObject private var viewModel: MovieDetailViewModel
    
    @State private var isFullOverview: Bool
    @State private var isDateSetup: Bool
    @State private var dateSetupType: DateSetupType
    
    let movie: MovieData
    let size: CGSize
    
    init(
        viewModel: MovieDetailViewModel,
        isFullOverview: Bool = false,
        isDateSetup: Bool = false,
        dateSetupType: DateSetupType = .want,
        movie: MovieData,
        size: CGSize
    ) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self._isFullOverview = State(wrappedValue: isFullOverview)
        self._isDateSetup = State(wrappedValue: isDateSetup)
        self._dateSetupType = State(wrappedValue: dateSetupType)
        self.movie = movie
        self.size = size
    }
    
    var body: some View {
        VStack {
            if !viewModel.output.networkConnect {
                UnnetworkedView(refreshAction: viewModel.action(.refresh))
            } else {
                infoSection()
            }
        }
        .task { viewModel.action(.viewOnTask) }
        .ignoresSafeArea(.all, edges: .bottom)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.background)
        .toolbar(.hidden, for: .tabBar)
        .valueChanged(value: dateSetupType) { newValue in
            // dateSetupType의 변화를 확인하지 않으면 속성 값이 바뀌지 않음.
        }
        .popupAlert(
            isPresented: Binding(
                get: { viewModel.output.isShowAlert },
                set: { _ in viewModel.action(.onDismissAlert) }
            ),
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
            .padding(.bottom, 28)
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
        VStack {
            HStack(alignment: .lastTextBaseline) {
                Text(verbatim: viewModel.output.movieDetail.title)
                    .lineLimit(2)
                    .font(.ibmPlexMonoSemiBold(size: 26))
                    .foregroundStyle(.appText)
                Spacer()
                Image(systemName: "star.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundStyle(.yellow)
                Text(verbatim: "\(String(format: "%.1f", viewModel.output.movieDetail.rating))")
                    .font(.system(size: 26))
                    .foregroundStyle(.appText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(alignment: .lastTextBaseline) {
                Text(verbatim: viewModel.output.movieDetail.releaseDate.replacingOccurrences(of: "-", with: "."))
                Text(verbatim: "\(viewModel.output.movieDetail.runtime / 60)h \(viewModel.output.movieDetail.runtime % 60)m")
                    .padding(.leading, 8)
            }
            .font(.ibmPlexMonoSemiBold(size: 16))
            .foregroundStyle(.appText)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private func wantWatchedSection() -> some View {
        HStack {
            Button {
                dateSetupType = .want
                coordinator.presentSheet(.dateSetup(movie, dateSetupType))
            } label: {
                Text(verbatim: "WANT")
                    .appButtonText()
            }
            
            Button {
                dateSetupType = .watched
                coordinator.presentSheet(.dateSetup(movie, dateSetupType))
            } label: {
                Text(verbatim: "WATHCED")
                    .appButtonText()
            }
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private func overviewSection() -> some View {
        VStack {
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
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private func castcrewSection() -> some View {
        InfoHeader(titleKey: "castcrew")
            .padding(.horizontal)
        ScrollView(.horizontal) {
            LazyHStack {
                ForEach(viewModel.output.creditInfo, id: \.id) { credit in
                    creditButton(credit: credit, size: CGSize(width: 90, height: 90))
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }
    
    @ViewBuilder
    private func genreSection() -> some View {
        VStack {
            InfoHeader(titleKey: "genre")
                .padding(.horizontal)
            ScrollView(.horizontal) {
                LazyHStack(spacing: 12) {
                    ForEach(viewModel.output.movieDetail.genres, id: \.id) { genre in
                        Text(verbatim: "\(genre.name)")
                            .font(.ibmPlexMonoMedium(size: 20))
                            .foregroundStyle(.app)
                            .padding(.horizontal)
                            .padding(.vertical, 4)
                            .overlay {
                                Rectangle()
                                    .fill(Color(uiColor: .app).opacity(0.2))
                            }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 8)
        }
    }
    
    @ViewBuilder
    private func similarSection() -> some View {
        MoreHeader(usedTo: .similar(viewModel.movieId))
        
        ScrollView(.horizontal) {
            LazyHStack {
                ForEach(viewModel.output.movieSimilars) { similar in
                    posterButton(
                        movie: similar,
                        size: (
                            poster: size,
                            cell: CGSize(
                                width: size.width * 0.5,
                                height: size.height * 0.5
                            )
                        )
                    )
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }
    
    @ViewBuilder
    private func backdropSection() -> some View {
        InfoHeader(titleKey: "backdrop")
            .padding(.horizontal)
        
        ScrollView(.horizontal) {
            LazyHStack {
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
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }
    
    @ViewBuilder
    private func posterSection() -> some View {
        InfoHeader(titleKey: "poster")
            .padding(.horizontal)
        
        ScrollView(.horizontal) {
            LazyHStack {
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
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }
    
    @ViewBuilder
    private func videoSection() -> some View {
        InfoHeader(titleKey: "video")
            .padding(.horizontal)
        
        ScrollView(.horizontal) {
            LazyHStack {
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
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: Movie Poster Cell
extension MovieDetailView {
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

// MARK: Cast & Crew Cell
extension MovieDetailView {
    @ViewBuilder
    private func creditButton(credit: CreditInfo, size: CGSize) -> some View {
        Button {
            creditTapped(credit: credit)
        } label: {
            creditLabel(credit: credit, size: size)
        }
    }
    
    private func creditTapped(credit: CreditInfo) {
        coordinator.push(.personDetail(credit._id))
    }
    
    @ViewBuilder
    private func creditLabel(credit: CreditInfo, size: CGSize) -> some View {
        VStack {
            let url = URL(string: ImageURL.tmdb(image: credit.profilePath).urlString)
            PosterImage(
                url: url,
                size: CGSize(width: 90, height: 90),
                title: credit.name.replacingOccurrences(of: " ", with: "\n"),
                isDownsampling: true
            )
            .clipShape(Circle())
            .grayscale(colorScheme == .dark ? 1 : 0)
            
            Text(verbatim: "\(credit.role.replacingOccurrences(of: " ", with: "\n"))")
                .font(.ibmPlexMonoRegular(size: 14))
                .foregroundStyle(.appText)
                .frame(width: 90)
            Text(verbatim: "\(credit.name)")
                .font(.ibmPlexMonoRegular(size: 14))
                .foregroundStyle(.appText)
                .frame(width: 90)
        }
        .frame(maxHeight: .infinity, alignment: .top)
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
