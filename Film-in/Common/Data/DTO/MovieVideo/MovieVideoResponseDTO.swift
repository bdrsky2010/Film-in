//
//  MovieVideoResponseDTO.swift
//  Film-in
//
//  Created by Minjae Kim on 9/24/24.
//

import Foundation

struct MovieVideoResponseDTO: Decodable {
    struct Video: Decodable {
        let iso639_1: String
        let iso3166_1: String
        let name: String
        let key: String
        let site: String
        let size: Int
        let type: String
        let official: Bool
        let publishedAt: String
        let id: String
        
        enum CodingKeys: String, CodingKey {
            case iso639_1 = "iso_639_1"
            case iso3166_1 = "iso_3166_1"
            case name
            case key
            case site
            case size
            case type
            case official
            case publishedAt = "published_at"
            case id
        }
    }
    
    let id: Int
    let results: [Video]
}
