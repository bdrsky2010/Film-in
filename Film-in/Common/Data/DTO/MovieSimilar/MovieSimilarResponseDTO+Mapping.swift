//
//  MovieSimilarResponseDTO.swift
//  Film-in
//
//  Created by Minjae Kim on 9/23/24.
//

import Foundation

struct MovieSimilarResponseDTO: Decodable {
    let page: Int
    let results: [TMDBMovieResponseDTO]
    let totalPages: Int
    
    enum CodingKeys: String, CodingKey {
        case page
        case results
        case totalPages = "total_pages"
    }
}

extension MovieSimilarResponseDTO {
    func toEntity() -> MovieSimilar {
        return MovieSimilar(
            page: self.page,
            totalPage: self.totalPages,
            movies: self.results
                .map {
                    MovieSimilar.Movie(
                        id: $0.id,
                        title: $0.title ?? "",
                        poster: $0.posterPath ?? ""
                    )
                }
        )
    }
    
    func toEntity() -> HomeMovie {
        return HomeMovie(
            page: self.page,
            totalPage: self.totalPages,
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
