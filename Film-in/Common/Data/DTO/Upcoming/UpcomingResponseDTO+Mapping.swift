//
//  UpcomingResponseDTO.swift
//  Film-in
//
//  Created by Minjae Kim on 9/21/24.
//

import Foundation

struct UpcomingResponseDTO: Decodable {
    let dates: PeriodResponseDTO
    let page: Int
    let results: [TMDBMovieResponseDTO]
}

extension UpcomingResponseDTO {
    func toEntity() -> HomeMovie {
        return HomeMovie(
            period: .init(
                minimum: dates.minimum,
                maximum: dates.maximum
            ),
            page: self.page,
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
