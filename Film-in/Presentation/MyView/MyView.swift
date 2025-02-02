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
    
    @EnvironmentObject var coordinator: Coordinator
    
    @StateObject private var viewModel: MyViewModel
    
    @State private var posterSize: CGSize
    
    init(
        viewModel: MyViewModel,
        posterSize: CGSize = .zero
    ) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self._posterSize = State(wrappedValue: posterSize)
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                calendarSection()
                contentSection()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .popupAlert(
            isPresented: $viewModel.output.isRequestDelete,
            contentModel: PopupAlertModel(
                phrase: "deleteRequestPhrase",
                normal: "delete",
                cancel: "cancel"
            ),
            heightType: .normal
        ) {
            viewModel.action(.realDelete(movieId: viewModel.output.deleteMovieId))
        }
    }
}

extension MyView {
    @ViewBuilder
    private func calendarSection() -> some View {
        CalendarView(viewModel: viewModel)
            .padding(.horizontal)
    }
    
    @ViewBuilder
    private func contentSection() -> some View {
        GeometryReader { proxy in
            List {
                wantSection(proxy: proxy)
                watchedSection(proxy: proxy)
            }
            .task {
                posterSize = CGSize(width: proxy.size.width * 0.7, height: proxy.size.width * 0.7 * 1.5)
                viewModel.action(.viewOnTask)
            }
            .listStyle(.plain)
        }
    }
    
    @ViewBuilder
    private func wantSection(proxy: GeometryProxy) -> some View {
        Text(verbatim: "WANT")
            .font(.ibmPlexMonoSemiBold(size: 24))
            .foregroundStyle(.appText)
            .frame(maxWidth: proxy.size.width, alignment: .leading)
        
        let wantMovies = user.first?.wantMovies.filter({ Calendar.current.isDate(viewModel.output.selectDate, inSameDayAs: $0.date) }) ?? []
        ForEach(wantMovies, id: \.id) { movie in
            ZStack {
                let url = URL(string: ImageURL.tmdb(image: movie.backdrop).urlString)
                PosterImage(
                    url: url,
                    size: CGSize(
                        width: proxy.size.width - 40,
                        height: (proxy.size.width - 40) * 0.56
                    ),
                    title: movie.title,
                    isDownsampling: true
                )
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .foregroundStyle(.black).opacity(0.5)
                        .frame(height: proxy.size.width * 0.56 * 0.2)
                }
                .overlay(alignment: .bottomLeading) {
                    Text(verbatim: movie.title)
                        .foregroundStyle(.app)
                        .font(.ibmPlexMonoRegular(size: 16))
                        .lineLimit(2)
                        .frame(height: proxy.size.width * 0.56 * 0.2)
                        .padding(.leading, 20)
                }
                
                Button {
                    coordinator.push(.movieDetail(convertToMovieData(by: movie), posterSize))
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
    }
    
    @ViewBuilder
    private func watchedSection(proxy: GeometryProxy) -> some View {
        Text(verbatim: "WATCHED")
            .font(.ibmPlexMonoSemiBold(size: 24))
            .foregroundStyle(.appText)
            .frame(maxWidth: proxy.size.width, alignment: .leading)
        
        let watchedMovies = user.first?.watchedMovies.filter({ Calendar.current.isDate(viewModel.output.selectDate, inSameDayAs: $0.date) }) ?? []
        ForEach(watchedMovies, id: \.id) { movie in
            ZStack {
                let url = URL(string: ImageURL.tmdb(image: movie.backdrop).urlString)
                PosterImage(
                    url: url,
                    size: CGSize(
                        width: proxy.size.width - 40,
                        height: (proxy.size.width - 40) * 0.56
                    ),
                    title: movie.title,
                    isDownsampling: true
                )
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .foregroundStyle(.black).opacity(0.5)
                        .frame(height: proxy.size.width * 0.56 * 0.2)
                }
                .overlay(alignment: .bottomLeading) {
                    Text(verbatim: movie.title)
                        .foregroundStyle(.app)
                        .font(.ibmPlexMonoRegular(size: 16))
                        .lineLimit(2)
                        .frame(height: proxy.size.width * 0.56 * 0.2)
                        .padding(.leading, 20)
                }
                Button {
                    coordinator.push(.movieDetail(convertToMovieData(by: movie), posterSize))
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
}

extension MyView {
    private func convertToMovieData(by movieTable: MovieTable) -> MovieData {
        return MovieData(
            _id: movieTable.id,
            title: movieTable.title,
            poster: movieTable.poster,
            backdrop: movieTable.backdrop
        )
    }
}
