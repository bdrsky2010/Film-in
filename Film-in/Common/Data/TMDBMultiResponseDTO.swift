//
//  TMDBMultiResponseDTO.swift
//  Film-in
//
//  Created by Minjae Kim on 12/9/24.
//

import Foundation

struct TMDBMultiResponseDTO: Decodable {
    // Movie
    let title: String
    let originalTitle: String
    let releaseDate: String
    let video: Bool
    
    // TV
    let firstAirDate: String
    
    // Person
    let gender: Int
    let department: String
    let profilePath: String
    let knownFor: [TMDBMovieResponseDTO]
    
    // TV, Person
    let name: String
    let originalName: String
    
    // Movie, TV
    let backdropPath: String
    let overview: String
    let posterPath: String
    let originalLanguage: String
    let genreIds: [Int]
    let voteAverage: Double
    let voteCount: Int
    
    // Common
    let id: Int
    let mediaType: String
    let adult: Bool
    let popularity: Double
    
    enum CodingKeys: String, CodingKey {
        case title
        case originalTitle = "original_title"
        case releaseDate = "release_date"
        case video
        case firstAirDate = "first_air_date"
        case gender
        case department = "known_for_department"
        case profilePath = "profile_path"
        case knownFor = "known_for"
        case name
        case originalName = "original_name"
        case backdropPath = "backdrop_path"
        case overview
        case posterPath = "poster_path"
        case originalLanguage = "original_language"
        case genreIds = "genre_ids"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
        case id
        case mediaType = "media_type"
        case adult
        case popularity
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
        self.originalTitle = try container.decodeIfPresent(String.self, forKey: .originalTitle) ?? ""
        self.releaseDate = try container.decodeIfPresent(String.self, forKey: .releaseDate) ?? ""
        self.video = try container.decodeIfPresent(Bool.self, forKey: .video) ?? false
        self.firstAirDate = try container.decodeIfPresent(String.self, forKey: .firstAirDate) ?? ""
        self.gender = try container.decodeIfPresent(Int.self, forKey: .gender) ?? -1
        self.department = try container.decodeIfPresent(String.self, forKey: .department) ?? ""
        self.profilePath = try container.decodeIfPresent(String.self, forKey: .profilePath) ?? ""
        self.knownFor = try container.decodeIfPresent([TMDBMovieResponseDTO].self, forKey: .knownFor) ?? []
        self.name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        self.originalName = try container.decodeIfPresent(String.self, forKey: .originalName) ?? ""
        self.backdropPath = try container.decodeIfPresent(String.self, forKey: .backdropPath) ?? ""
        self.overview = try container.decodeIfPresent(String.self, forKey: .overview) ?? ""
        self.posterPath = try container.decodeIfPresent(String.self, forKey: .posterPath) ?? ""
        self.originalLanguage = try container.decodeIfPresent(String.self, forKey: .originalLanguage) ?? ""
        self.genreIds = try container.decodeIfPresent([Int].self, forKey: .genreIds) ?? []
        self.voteAverage = try container.decodeIfPresent(Double.self, forKey: .voteAverage) ?? 0.0
        self.voteCount = try container.decodeIfPresent(Int.self, forKey: .voteCount) ?? 0
        self.id = try container.decode(Int.self, forKey: .id)
        self.mediaType = try container.decodeIfPresent(String.self, forKey: .mediaType) ?? ""
        self.adult = try container.decode(Bool.self, forKey: .adult)
        self.popularity = try container.decode(Double.self, forKey: .popularity)
    }
}
