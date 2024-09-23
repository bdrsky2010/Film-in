//
//  MovieCreditResponseDTO.swift
//  Film-in
//
//  Created by Minjae Kim on 9/23/24.
//

import Foundation

struct MovieCreditResponseDTO: Decodable {
    struct Cast: Decodable {
        let adult: Bool
        let gender: Int
        let id: Int
        let department: String
        let name: String
        let originName: String
        let popularity: Double
        let profilePath: String?
        let castId: Int
        let character: String
        let creditId: String
        let order: Int
        
        enum CodingKeys: String, CodingKey {
            case adult
            case gender
            case id
            case department = "known_for_department"
            case name
            case originName = "original_name"
            case popularity
            case profilePath = "profile_path"
            case castId = "cast_id"
            case character
            case creditId = "credit_id"
            case order
        }
    }
    
    struct Crew: Decodable {
        let adult: Bool
        let gender: Int
        let id: Int
        let name: String
        let originName: String
        let popularity: Double
        let profilePath: String?
        let creditId: String
        let department: String
        let job: String
        
        enum CodingKeys: String, CodingKey {
            case adult
            case gender
            case id
            case name
            case originName = "original_name"
            case popularity
            case profilePath = "profile_path"
            case creditId = "credit_id"
            case department
            case job
        }
    }
    
    let id: Int
    let cast: [Cast]
    let crew: [Crew]
}
