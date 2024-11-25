//
//  PeopleMovieResponseDTO.swift
//  Film-in
//
//  Created by Minjae Kim on 9/30/24.
//

import Foundation

struct PeopleMovieResponseDTO: Decodable {
    let cast: [TMDBMovieResponseDTO]
    let id: Int
}

extension PeopleMovieResponseDTO {
    func toEntity() -> PersonMovie {
        return PersonMovie(
            id: self.id,
            movies: self.cast
                .map {
                    MovieData(
                        _id: $0.id,
                        title: $0.title,
                        poster: $0.posterPath,
                        backdrop: $0.backdropPath
                    )
                }
        )
    }
}
