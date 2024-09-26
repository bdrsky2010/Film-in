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
    var toEntity: HomeMovie {
        return HomeMovie(
            period: .init(
                minimum: dates.minimum,
                maximum: dates.maximum
            ),
            page: self.page,
            movies: self.results
                .map {
                    .init(
                        id: $0.id,
                        poster: $0.posterPath ?? ""
                    )
                }
        )
    }
}
