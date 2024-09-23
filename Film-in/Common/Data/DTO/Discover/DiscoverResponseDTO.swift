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
