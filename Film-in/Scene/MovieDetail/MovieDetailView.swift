//
//  MovieDetailView.swift
//  Film-in
//
//  Created by Minjae Kim on 9/27/24.
//

import SwiftUI

struct MovieDetailView: View {
    @Binding var offset: CGFloat
    @Binding var showDetailView: Bool
    
    var namespace: Namespace.ID
    
    let movie: HomeMovie.Movie
    let size: CGSize
    
    var body: some View {
        VStack {
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
                VStack {
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
                }
                .padding()
                .modifier(OffsetModifier(offset: $offset))
            }
        }
        .coordinateSpace(name: "SCROLL")
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.background)
        .statusBar(hidden: true)
        .toolbar(.hidden, for: .tabBar)
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
        .sheet(isPresented: .constant(true)) {
            MovieInfoView(
                viewModel: MovieInfoViewModel(
                    movieInfoService: DefaultMovieInfoService(
                        tmdbRepository: DefaultTMDBRepository.shared,
                        databaseRepository: RealmRepository.shared
                    ),
                    networkMonitor: NetworkMonitor.shared,
                    movieId: movie._id
                ),
                posterSize: size
            )
            .presentationDetents([.height(160), .large])
            .presentationBackgroundInteraction(.enabled(upThrough: .height(160)))
            .presentationCornerRadius(0)
            .presentationDragIndicator(.visible)
            .interactiveDismissDisabled()
        }
    }
}

#Preview {
    @Namespace var namespace
    return MovieDetailView(offset: .constant(0), showDetailView: .constant(true), namespace: namespace, movie: .init(_id: 1022789, title: "인사이드 아웃 2", poster: "/x2BHx02jMbvpKjMvbf8XxJkYwHJ.jpg"), size: CGSize(width: 275.09999999999997, height: 412.65))
}
