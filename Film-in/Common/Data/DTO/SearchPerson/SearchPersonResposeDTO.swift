//
//  SearchPersonResposeDTO.swift
//  Film-in
//
//  Created by Minjae Kim on 9/23/24.
//

import Foundation

struct SearchPersonResposeDTO: Decodable {
    struct Person: Decodable {
        let adult: Bool
        let gender: Int
        let id: Int
        let department: String
        let name: String
        let originName: String
        let popularity: Double
        let profilePath: String
        let knownFor: [TMDBMovieResponseDTO]
        
        enum CodingKeys: String, CodingKey {
            case adult
            case gender
            case id
            case department = "known_for_department"
            case name
            case originName = "original_name"
            case popularity
            case profilePath = "profile_path"
            case knownFor = "known_for"
        }
    }
    
    let page: Int
    let results: [Person]
    let totalPage: Int
    
    enum CodingKeys: String, CodingKey {
        case page
        case results
        case totalPage = "total_pages"
    }
}
