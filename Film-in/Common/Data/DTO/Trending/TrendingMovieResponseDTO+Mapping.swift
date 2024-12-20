//
//  TrendingMovieResponseDTO.swift
//  Film-in
//
//  Created by Minjae Kim on 9/21/24.
//

import Foundation

struct TrendingMovieResponseDTO: Decodable {
    let results: [TMDBMovieResponseDTO]
}

extension TrendingMovieResponseDTO {
//    func toEntity() -> HomeMovie {
//        return HomeMovie(
//            movies: self.results
//                .map {
//                    MovieData(
//                        _id: $0.id,
//                        title: $0.title,
//                        poster: $0.posterPath,
//                        backdrop: $0.backdropPath
//                    )
//                }
//        )
//    }
    func toEntity() -> [MovieData] {
        return results
            .map {
                MovieData(
                    _id: $0.id,
                    title: $0.title,
                    poster: $0.posterPath,
                    backdrop: $0.backdropPath
                )
            }
    }
}
