//
//  TrendingResponseDTO.swift
//  Film-in
//
//  Created by Minjae Kim on 9/21/24.
//

import Foundation

struct TrendingResponseDTO: Decodable {
    let results: [TMDBMovieResponseDTO]
}

extension TrendingResponseDTO {
    var toEntity: HomeMovie {
        return HomeMovie(
            movies: self.results
                .map {
                    HomeMovie.Movie(
                        id: $0.id,
                        poster: $0.posterPath ?? ""
                    )
                }
        )
    }
}
