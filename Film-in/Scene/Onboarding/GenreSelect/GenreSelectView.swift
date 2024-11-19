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
            titleSection()
            contentSection()
        }
        .sheet(isPresented: .constant(true)) {
            SelectedGenreSheetView(viewModel: viewModel)
        }
        .frame(maxWidth: .infinity)
        .task {
            viewModel.action(.viewOnTask)
        }
        .apiRequestErrorAlert(isPresented: $viewModel.output.isShowAlert) {
            viewModel.action(.refresh)
        }
    }
    
    @ViewBuilder
    private func titleSection() -> some View {
        Text("genreSelectTitle")
            .font(.ibmPlexMonoSemiBold(size: 30))
            .foregroundStyle(.appText)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
    }
    
    @ViewBuilder
    private func contentSection() -> some View {
        if viewModel.output.networkConnect {
            LazyVGrid(columns: columns) {
                ForEach(viewModel.output.genres, id: \.id) { genre in
                    Circle()
                        .fill(viewModel.output.selectedGenres.contains(genre) ? Color(.app) : Color(.app).opacity(0.3))
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
        }
    }
}

fileprivate struct SelectedGenreSheetView: View {
    @ObservedObject private var viewModel: GenreSelectViewModel
    
    @AppStorage("onboarding") private var isOnboarding = false
    
    init(viewModel: GenreSelectViewModel) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVStack(alignment: .center, spacing: 15) {
                    ForEach(viewModel.output.selectedGenreRows, id: \.self) { row in
                        HStack(spacing: 12) {
                            ForEach(row, id: \.id) { genre in
                                GenreView(genre: genre)
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
                isOnboarding = true
            } label: {
                Text("done")
                    .font(.ibmPlexMonoSemiBold(size: 20))
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(Color(uiColor: .app).opacity(0.3))
                    .foregroundStyle(.app)
            }
        }
        .padding()
        .presentationDetents([.height(200)])
        .presentationBackgroundInteraction(.enabled(upThrough: .height(200)))
        .presentationCornerRadius(0)
        .presentationDragIndicator(.visible)
        .interactiveDismissDisabled()
    }
}

fileprivate struct GenreView: View {
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

fileprivate struct NotConnectView: View {
    @ObservedObject var viewModel: GenreSelectViewModel
    
    var body: some View {
        Text("notConnectInternet")
            .font(.ibmPlexMonoSemiBold(size: 20))
            .foregroundStyle(.appText)
        Button {
            viewModel.action(.refresh)
        } label: {
            Text("refresh")
                .font(.ibmPlexMonoMedium(size: 20))
                .underline()
                .foregroundStyle(.app)
        }
    }
}
