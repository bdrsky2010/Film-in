//
//  GenreSelectView.swift
//  Film-in
//
//  Created by Minjae Kim on 9/24/24.
//

import SwiftUI

struct GenreSelectView: View {
    @StateObject private var viewModel: GenreSelectViewModel
    
    private let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    init(viewModel: GenreSelectViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ScrollView {
            Text("genreSelectTitle")
                .font(.notoSansMedium(size: 30))
                .foregroundStyle(.appText)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
            if viewModel.output.networkConnect {
                LazyVGrid(columns: columns) {
                    ForEach(viewModel.output.genres, id: \.id) { genre in
                        Circle()
                            .fill(viewModel.output.selectedGenres.contains(genre) ? Color(uiColor: .app) : Color(uiColor: .app).opacity(0.3))
                            .frame(width: 100, height: 100)
                            .overlay(
                                Text(genre.name)
                                    .foregroundStyle(viewModel.output.selectedGenres.contains(genre) ? .white : Color(uiColor: .app))
                                    .multilineTextAlignment(.center)
                                    .padding(8)
                            )
                            .onTapGesture {
                                withAnimation {
                                    viewModel.action(.addGenre(genre))
                                }
                            }
                            .valueChanged(value: viewModel.output.selectedGenres) { _ in
                                viewModel.action(.changedGenres)
                            }
                    }
                }
                
                Rectangle()
                    .fill(.clear)
                    .frame(height: 200)
            } else {
                NotConnectView(viewModel: viewModel)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .border(.red)
            }
        }
        .sheet(isPresented: .constant(true)) {
            VStack {
                ScrollView {
                    LazyVStack(alignment: .center, spacing: 15) {
                        ForEach(viewModel.output.selectedGenreRows, id: \.self) { row in
                            HStack(spacing: 12) {
                                ForEach(row, id: \.id) { genre in
                                    SelectedGenreView(genre: genre)
                                        .onTapGesture {
                                            withAnimation {
                                                viewModel.action(.removeGenre(genre))
                                            }
                                        }
                                }
                            }
                        }
                    }
                }
                .frame(width: GenreHandler.windowWidth)

                Button {
                    viewModel.action(.createUser)
                } label: {
                    Text("done")
                        .font(.notoSansBold(size: 20))
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(Color(uiColor: .app).opacity(0.3))
                        .foregroundStyle(Color(uiColor: .app))
                }
            }
            .padding()
            .presentationDetents([.height(200)])
            .presentationBackgroundInteraction(.enabled(upThrough: .height(200)))
            .presentationCornerRadius(0)
            .presentationDragIndicator(.visible)
            .interactiveDismissDisabled()
        }
        .frame(maxWidth: .infinity)
        .task {
            viewModel.action(.viewOnTask)
        }
    }
}

struct SelectedGenreView: View {
    let genre: MovieGenre
    
    var body: some View {
        Text(genre.name)
            .font(.system(size: 16))
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .foregroundStyle(.white)
            .background(Color.init(uiColor: .app))
            .clipShape(Capsule())
    }
}

struct NotConnectView: View {
    @ObservedObject var viewModel: GenreSelectViewModel
    
    var body: some View {
        Text("notConnectInternet")
            .font(.notoSansBold(size: 20))
            .foregroundStyle(.appText)
        Button("refresh") {
            viewModel.action(.refresh)
        }
        .font(.notoSansMedium(size: 20))
        .foregroundStyle(.app)
    }
}

#Preview {
    GenreSelectView(
        viewModel: GenreSelectViewModel(
            genreSelectService: DefaultGenreSelectService(tmdbRepository: DefaultTMDBRepository.shared),
            networkMonitor: NetworkMonitor.shared,
            databaseRepository: RealmRepository.shared
        )
    )
}
