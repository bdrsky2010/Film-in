//
//  MyView.swift
//  Film-in
//
//  Created by Minjae Kim on 10/1/24.
//

import SwiftUI
import RealmSwift
import PopupView

struct MyView: View {
    @ObservedResults(UserTable.self) var user
    @StateObject private var viewModel: MyViewModel
    @State private var selection = Date()
    @State private var posterSize: CGSize = .zero
    
    init(
        viewModel: MyViewModel,
        selection: Date = Date(),
        posterSize: CGSize = .zero
    ) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self._selection = State(wrappedValue: selection)
        self._posterSize = State(wrappedValue: posterSize)
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                DatePicker("", selection: $selection, displayedComponents: [.date])
                    .datePickerStyle(.graphical)
                    .tint(.app)
                
//                CalendarView(viewModel: viewModel)
                
                GeometryReader { proxy in
                    List {
                        Text("WANT")
                            .font(.ibmPlexMonoSemiBold(size: 24))
                            .foregroundStyle(.appText)
                            .frame(maxWidth: proxy.size.width, alignment: .leading)
                        
                        let wantMovies = user.first?.wantMovies.filter({ Calendar.current.isDate(selection, inSameDayAs: $0.date) }) ?? []
                        ForEach(wantMovies, id: \.id) { movie in
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
                                    LazyView(
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
                                    )
                                } label: {
                                    EmptyView()
                                }
                                .opacity(0)
                            }
                        }
                        .onDelete { indexSet in
                            guard let index = indexSet.first else { return }
                            let wantMovieId = wantMovies[index].id
                            viewModel.action(.deleteGesture(movieId: wantMovieId))
                        }
                        
                        Text("WATCHED")
                            .font(.ibmPlexMonoSemiBold(size: 24))
                            .foregroundStyle(.appText)
                            .frame(maxWidth: proxy.size.width, alignment: .leading)
                        
                        let watchedMovies = user.first?.watchedMovies.filter({ Calendar.current.isDate(selection, inSameDayAs: $0.date) }) ?? []
                        ForEach(watchedMovies, id: \.id) { movie in
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
                        .onDelete { indexSet in
                            guard let index = indexSet.first else { return }
                            let watchedMovieId = watchedMovies[index].id
                            viewModel.action(.deleteGesture(movieId: watchedMovieId))
                        }
                    }
                    .task {
                        posterSize = CGSize(width: proxy.size.width * 0.7, height: proxy.size.width * 0.7 * 1.5)
                        
                        viewModel.action(.viewOnTask)
                    }
                    .listStyle(.plain)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .popup(isPresented: $viewModel.output.isRequestDelete) {
            VStack {
                Text("deleteRequestPhrase")
                    .font(.ibmPlexMonoSemiBold(size: 20))
                
                Spacer()
                
                HStack {
                    Button {
                        
                    } label: {
                        Text("cancel")
                            .font(.ibmPlexMonoSemiBold(size: 20))
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(Color(uiColor: .app).opacity(0.3))
                            .foregroundStyle(.app)
                    }
                    
                    Button {
                        viewModel.action(.realDelete(movieId: viewModel.output.deleteMovieId))
                    } label: {
                        Text("delete")
                            .font(.ibmPlexMonoSemiBold(size: 20))
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(Color(uiColor: .app).opacity(0.3))
                            .foregroundStyle(.app)
                    }
                }
            }
            .frame(width: 300, height: 120, alignment: .top)
            .padding()
            .background(.background)
        } customize: {
            $0
                .closeOnTapOutside(true)
                .backgroundColor(.appText.opacity(0.5))
        }
        
        
    }
}

#Preview {
    MyView(
        viewModel: MyViewModel(
            myViewService: DefaultMyViewService(
                databaseRepository: RealmRepository.shared,
                localNotificationManager: DefaultLocalNotificationManager.shared,
                calendarManager: DefaultCalendarManager()
            )
        )
    )
}
