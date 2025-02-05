//
//  MyView.swift
//  Film-in
//
//  Created by Minjae Kim on 10/1/24.
//

import SwiftUI
import RealmSwift

struct MyView: View {
    enum Section: CaseIterable {
        case want, watched
    }
    
    @ObservedResults(UserTable.self) var user
    
    @EnvironmentObject var coordinator: Coordinator
    
    @StateObject private var viewModel: MyViewModel
    
    @State private var wantMovies: [MovieTable]
    @State private var watchedMovies: [MovieTable]
    @State private var posterSize: CGSize
    
    init(
        viewModel: MyViewModel,
        posterSize: CGSize = .zero
    ) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self._wantMovies = State(wrappedValue: [])
        self._watchedMovies = State(wrappedValue: [])
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
                phrase: R.Phrase.deleteRequest,
                normal: R.Phrase.delete,
                cancel: R.Phrase.cancel
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
            .listStyle(.plain)
            .task {
                updateData(by: user, when: viewModel.output.selectDate)
                
                posterSize = CGSize(
                    width: proxy.size.width * 0.7,
                    height: proxy.size.width * 0.7 * 1.5
                )
                viewModel.action(.viewOnTask)
            }
        }
        .valueChanged(value: user) { _ in
            updateData(by: user, when: viewModel.output.selectDate)
        }
    }
    
    @ViewBuilder
    private func wantSection(proxy: GeometryProxy) -> some View {
        Text(R.Phrase.want)
            .font(.ibmPlexMonoSemiBold(size: 24))
            .foregroundStyle(.appText)
            .frame(maxWidth: proxy.size.width, alignment: .leading)
        
        ForEach(wantMovies, id: \.id) { movie in
            let movie = convertToMovieData(by: movie)
            movieButton(proxy: proxy, movie: movie, size: posterSize)
        }
        .onDelete { indexSet in
            guard let index = indexSet.first else { return }
            let wantMovieId = wantMovies[index].id
            viewModel.action(.deleteGesture(movieId: wantMovieId))
        }
    }
    
    @ViewBuilder
    private func watchedSection(proxy: GeometryProxy) -> some View {
        Text(R.Phrase.watched)
            .font(.ibmPlexMonoSemiBold(size: 24))
            .foregroundStyle(.appText)
            .frame(maxWidth: proxy.size.width, alignment: .leading)
        
        ForEach(watchedMovies, id: \.id) { movie in
            let movie = convertToMovieData(by: movie)
            movieButton(proxy: proxy, movie: movie, size: posterSize)
        }
        .onDelete { indexSet in
            guard let index = indexSet.first else { return }
            let watchedMovieId = watchedMovies[index].id
            viewModel.action(.deleteGesture(movieId: watchedMovieId))
        }
    }
}

extension MyView {
    @ViewBuilder
    private func movieButton(proxy: GeometryProxy, movie: MovieData, size: CGSize) -> some View {
        ZStack {
            movieLabel(proxy: proxy, movie: movie)
            Button {
                movieTapped(movie: movie, size: size)
            } label: {
                EmptyView()
            }
            .opacity(0)
        }
    }
    
    private func movieTapped(movie: MovieData, size: CGSize) {
        coordinator.push(.movieDetail(movie, size))
    }
    
    @ViewBuilder
    private func movieLabel(proxy: GeometryProxy, movie: MovieData) -> some View {
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
    
    private func updateData(by user: Results<UserTable>, when date: Date) {
        wantMovies = updateMovieData(by: user, for: .want, when: date)
        watchedMovies = updateMovieData(by: user, for: .watched, when: date)
    }
    
    private func updateMovieData(
        by user: Results<UserTable>,
        for section: Section,
        when date: Date
    ) -> [MovieTable] {
        switch section {
        case .want:
            user.first?.wantMovies.filter({ Calendar.current.isDate(viewModel.output.selectDate, inSameDayAs: $0.date) }) ?? []
        case .watched:
            user.first?.watchedMovies.filter({ Calendar.current.isDate(viewModel.output.selectDate, inSameDayAs: $0.date) }) ?? []
        }
    }
}
