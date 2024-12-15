//
//  TMDBPersonResponseDTO.swift
//  Film-in
//
//  Created by Minjae Kim on 12/5/24.
//

import Foundation

struct TMDBPersonResponseDTO: Decodable {
    let id: Int
    let name: String
    let originName: String
    let adult: Bool
    let popularity: Double
    let gender: Int
    let department: String
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
    
    init(from decoder: any Decoder) throws {
        let container: KeyedDecodingContainer<TMDBPersonResponseDTO.CodingKeys> = try decoder.container(keyedBy: TMDBPersonResponseDTO.CodingKeys.self)
        self.adult = try container.decode(Bool.self, forKey: TMDBPersonResponseDTO.CodingKeys.adult)
        self.gender = try container.decode(Int.self, forKey: TMDBPersonResponseDTO.CodingKeys.gender)
        self.id = try container.decode(Int.self, forKey: TMDBPersonResponseDTO.CodingKeys.id)
        self.department = try container.decodeIfPresent(String.self, forKey: TMDBPersonResponseDTO.CodingKeys.department) ?? ""
        self.name = try container.decode(String.self, forKey: TMDBPersonResponseDTO.CodingKeys.name)
        self.originName = try container.decode(String.self, forKey: TMDBPersonResponseDTO.CodingKeys.originName)
        self.popularity = try container.decode(Double.self, forKey: TMDBPersonResponseDTO.CodingKeys.popularity)
        self.profilePath = try container.decodeIfPresent(String.self, forKey: TMDBPersonResponseDTO.CodingKeys.profilePath) ?? ""
        self.knownFor = try container.decodeIfPresent([TMDBMovieResponseDTO].self, forKey: TMDBPersonResponseDTO.CodingKeys.knownFor) ?? []
    }
}
