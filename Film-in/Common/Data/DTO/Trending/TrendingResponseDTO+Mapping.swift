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
    func toEntity() -> HomeMovie {
        return HomeMovie(
            movies: self.results
                .map {
                    HomeMovie.Movie(
                        _id: $0.id,
                        title: $0.title ?? "",
                        poster: $0.posterPath ?? ""
                    )
                }
        )
    }
}
