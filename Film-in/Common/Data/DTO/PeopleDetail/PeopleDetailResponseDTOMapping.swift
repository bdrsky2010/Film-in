//
//  PeopleDetailResponseDTO.swift
//  Film-in
//
//  Created by Minjae Kim on 9/24/24.
//

import Foundation

struct PeopleDetailResponseDTO: Decodable {
    let adult: Bool
    let alsoKnownAs: [String]
    let biography: String
    let birthday: String
    let deathday: String
    let gender: Int
    let homepage: String
    let id: Int
    let imdbId: String
    let department: String
    let name: String
    let placeOfBirth: String
    let popularity: Double
    let profilePath: String
    
    enum CodingKeys: String, CodingKey {
        case adult
        case alsoKnownAs = "also_known_as"
        case biography
        case birthday
        case deathday
        case gender
        case homepage
        case id
        case imdbId = "imdb_id"
        case department = "known_for_department"
        case name
        case placeOfBirth = "place_of_birth"
        case popularity
        case profilePath = "profile_path"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.adult = try container.decode(Bool.self, forKey: .adult)
        self.alsoKnownAs = try container.decode([String].self, forKey: .alsoKnownAs)
        self.biography = try container.decode(String.self, forKey: .biography)
        self.birthday = try container.decodeIfPresent(String.self, forKey: .birthday) ?? ""
        self.deathday = try container.decodeIfPresent(String.self, forKey: .deathday) ?? ""
        self.gender = try container.decode(Int.self, forKey: .gender)
        self.homepage = try container.decodeIfPresent(String.self, forKey: .homepage) ?? ""
        self.id = try container.decode(Int.self, forKey: .id)
        self.imdbId = try container.decode(String.self, forKey: .imdbId)
        self.department = try container.decode(String.self, forKey: .department)
        self.name = try container.decode(String.self, forKey: .name)
        self.placeOfBirth = try container.decodeIfPresent(String.self, forKey: .placeOfBirth) ?? ""
        self.popularity = try container.decode(Double.self, forKey: .popularity)
        self.profilePath = try container.decode(String.self, forKey: .profilePath)
    }
}

extension PeopleDetailResponseDTO {
    func toEntity() -> PersonDetail {
        return PersonDetail(
            id: self.id,
            name: self.name,
            birthday: self.birthday,
            placeOfBirth: self.placeOfBirth,
            profilePath: self.profilePath
        )
    }
}
