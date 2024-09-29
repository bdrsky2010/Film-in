//
//  MovieInfoView.swift
//  Film-in
//
//  Created by Minjae Kim on 9/27/24.
//

import SwiftUI
import Kingfisher
import PopupView
import YouTubePlayerKit

struct MovieInfoView: View {
    @StateObject private var viewModel: MovieInfoViewModel
    
    @State private var isFullOverview: Bool
    
    let posterSize: CGSize
    
    init(viewModel: MovieInfoViewModel, isFullOverview: Bool = false, posterSize: CGSize) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self._isFullOverview = State(wrappedValue: isFullOverview)
        self.posterSize = posterSize
    }
    
    var body: some View {
        ScrollView {
            if !viewModel.output.networkConnect {
                NotConnectView(viewModel: viewModel)
            } else {
                LazyVStack {
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
                    
                    InfoHeader(titleKey: "overview")
                        .padding(.top)
                    Text(viewModel.output.movieDetail.overview)
                        .font(.ibmPlexMonoMedium(size: 18))
                        .foregroundStyle(.appText)
                        .lineLimit(isFullOverview ? nil : 4)
                        .multilineTextAlignment(.leading)
                        .padding(4)
                    
                    Button {
                        withAnimation(.easeInOut) {
                            isFullOverview.toggle()
                        }
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
                                Button {
                                    print(person.role)
                                    print(person.name)
                                } label: {
                                    VStack {
                                        let url = URL(string: ImageURL.tmdb(image: person.profilePath).urlString)
                                        PosterImage(
                                            url: url,
                                            size: CGSize(width: 90, height: 90),
                                            title: person.name.replacingOccurrences(of: " ", with: "\n")
                                        )
                                        .clipShape(Circle())
                                        .grayscale(1)
                                        
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
                    
                    InfoHeader(titleKey: "simliar")
                    ScrollView(.horizontal) {
                        LazyHStack(spacing: 12) {
                            ForEach(viewModel.output.movieSimilars) { similar in
                                let url = URL(string: ImageURL.tmdb(image: similar.poster).urlString)
                                PosterImage(
                                    url: url,
                                    size: CGSize(
                                        width: posterSize.width * 0.5,
                                        height: posterSize.height * 0.5
                                    ),
                                    title: similar.title
                                )
                                .padding(.horizontal, 8)
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
                                        width: posterSize.height * 0.4 * backdrop.ratio,
                                        height: posterSize.height * 0.4
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
                                    // Overlay ViewBuilder closure to place an overlay View
                                    // for the current `YouTubePlayer.State`
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
                                    width: posterSize.height * 0.4 * 1.778,
                                    height: posterSize.height * 0.4
                                )
                                .padding(.horizontal, 8)
                            }
                        }
                    }
                }
                .padding(.vertical, 8)
            }
        }
        .scrollIndicators(.hidden)
        .padding(.horizontal)
        .padding(.top, 20)
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

fileprivate struct NotConnectView: View {
    @ObservedObject var viewModel: MovieInfoViewModel
    
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

#Preview {
    @Namespace var namespace
    return MovieDetailView(offset: .constant(0), showDetailView: .constant(true), namespace: namespace, movie: .init(_id: 1022789, title: "인사이드 아웃 2", poster: "/x2BHx02jMbvpKjMvbf8XxJkYwHJ.jpg"), size: CGSize(width: 275.09999999999997, height: 412.65))
}
