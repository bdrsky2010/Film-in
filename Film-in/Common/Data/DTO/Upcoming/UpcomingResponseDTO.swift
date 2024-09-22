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
