//
//  MyView.swift
//  Film-in
//
//  Created by Minjae Kim on 10/1/24.
//

import SwiftUI
import RealmSwift

struct MyView: View {
    @ObservedResults(UserTable.self) var user
    @State private var selection = Date()
    @State private var posterSize: CGSize = .zero
    
    var body: some View {
        NavigationStack {
            VStack {
                DatePicker("", selection: $selection, displayedComponents: [.date])
                    .datePickerStyle(.graphical)
                    .tint(.app)
                
                GeometryReader { proxy in
                    List {
                        Text("WANT")
                            .font(.ibmPlexMonoSemiBold(size: 24))
                            .foregroundStyle(.appText)
                            .frame(maxWidth: proxy.size.width, alignment: .leading)
                        
                        ForEach(user.first?.wantMovies.filter({ Calendar.current.isDate(selection, inSameDayAs: $0.date) }) ?? [], id: \.id) { movie in
                            ZStack {
                                let url = URL(string: ImageURL.tmdb(image: movie.backdrop).urlString)
                                PosterImage(
                                    url: url,
                                    size: CGSize(
                                        width: proxy.size.width - 40,
                                        height: (proxy.size.width - 40) * 0.56
                                    ),
                                    title: movie.title
                                )
                                .overlay(alignment: .bottom) {
                                    Rectangle()
                                        .foregroundStyle(.black).opacity(0.5)
                                        .frame(height: proxy.size.width * 0.56 * 0.2)
                                }
                                .overlay(alignment: .bottomLeading) {
                                    Text(movie.title)
                                        .foregroundStyle(.app)
                                        .font(.ibmPlexMonoRegular(size: 16))
                                        .lineLimit(2)
                                        .frame(height: proxy.size.width * 0.56 * 0.2)
                                        .padding(.leading, 20)
                                }
                                
                                NavigationLink {
                                    MovieDetailView(
                                        movie: .init(
                                            _id: movie.id,
                                            title: movie.title,
                                            poster: movie.poster,
                                            backdrop: movie.backdrop
                                        ),
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
                                } label: {
                                    EmptyView()
                                }
                                .opacity(0)
                            }
                        }
                        
                        Text("WATCHED")
                            .font(.ibmPlexMonoSemiBold(size: 24))
                            .foregroundStyle(.appText)
                            .frame(maxWidth: proxy.size.width, alignment: .leading)
                        
                        ForEach(user.first?.watchedMovies.filter({ Calendar.current.isDate(selection, inSameDayAs: $0.date) }) ?? [], id: \.id) { movie in
                            ZStack {
                                let url = URL(string: ImageURL.tmdb(image: movie.backdrop).urlString)
                                PosterImage(
                                    url: url,
                                    size: CGSize(
                                        width: proxy.size.width - 40,
                                        height: (proxy.size.width - 40) * 0.56
                                    ),
                                    title: movie.title
                                )
                                .overlay(alignment: .bottom) {
                                    Rectangle()
                                        .foregroundStyle(.black).opacity(0.5)
                                        .frame(height: proxy.size.width * 0.56 * 0.2)
                                }
                                .overlay(alignment: .bottomLeading) {
                                    Text(movie.title)
                                        .foregroundStyle(.app)
                                        .font(.ibmPlexMonoRegular(size: 16))
                                        .lineLimit(2)
                                        .frame(height: proxy.size.width * 0.56 * 0.2)
                                        .padding(.leading, 20)
                                }
                                
                                NavigationLink {
                                    MovieDetailView(
                                        movie: .init(
                                            _id: movie.id,
                                            title: movie.title,
                                            poster: movie.poster,
                                            backdrop: movie.backdrop
                                        ),
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
                                } label: {
                                    EmptyView()
                                }
                                .opacity(0)
                            }
                        }
                    }
                    .task {
                        posterSize = CGSize(width: proxy.size.width * 0.7, height: proxy.size.width * 0.7 * 1.5)
                    }
                    .listStyle(.plain)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

#Preview {
    MyView()
}
