//
//  NowPlayingResponseDTO.swift
//  Film-in
//
//  Created by Minjae Kim on 9/21/24.
//

import Foundation

struct NowPlayingResponseDTO: Decodable {
    let dates: PeriodResponseDTO
    let page: Int
    let results: [TMDBMovieResponseDTO]
    let totalPage: Int
    
    enum CodingKeys: String, CodingKey {
        case dates
        case page
        case results
        case totalPage = "total_pages"
    }
}

extension NowPlayingResponseDTO {
    func toEntity() -> HomeMovie {
        return HomeMovie(
            period: .init(
                minimum: dates.minimum,
                maximum: dates.maximum
            ),
            page: self.page,
            totalPage: self.totalPage,
            movies: self.results
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
