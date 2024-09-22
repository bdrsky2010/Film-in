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
