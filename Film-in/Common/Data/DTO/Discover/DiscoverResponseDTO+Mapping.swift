//
//  DiscoverResponseDTO.swift
//  Film-in
//
//  Created by Minjae Kim on 9/22/24.
//

import Foundation

struct DiscoverResponseDTO: Decodable {
    let page: Int
    let results: [TMDBMovieResponseDTO]
    let totalPage: Int
    
    enum CodingKeys: String, CodingKey {
        case page
        case results
        case totalPage = "total_pages"
    }
}

extension DiscoverResponseDTO {
    var toEntity: HomeMovie {
        return HomeMovie(
            page: self.page,
            totalPage: self.totalPage,
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
