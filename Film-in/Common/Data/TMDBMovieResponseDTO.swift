//
//  TMDBMovieResponseDTO.swift
//  Film-in
//
//  Created by Minjae Kim on 9/21/24.
//

import Foundation

struct TMDBMovieResponseDTO: Decodable {
    let backdropPath: String // upcoming에서 없을 수 있음
    let id: Int
    let title: String
    let originTitle: String
    let overview: String
    let posterPath: String
    let mediaType: String? // nowPlaying에서 없을 수 있음
    let adult: Bool
    let originLanguage: String
    let genreIds: [Int]
    let popularity: Double
    let releaseDate: String
    let video: Bool
    let voteAverage: Double
    let voteCount: Int
    
    enum CodingKeys: String, CodingKey {
        case backdropPath = "backdrop_path"
        case id
        case title
        case originTitle = "original_title"
        case overview
        case posterPath = "poster_path"
        case mediaType = "media_type"
        case adult
        case originLanguage = "original_language"
        case genreIds = "genre_ids"
        case popularity
        case releaseDate = "release_date"
        case video
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.backdropPath = try container.decodeIfPresent(String.self, forKey: .backdropPath) ?? ""
        self.id = try container.decode(Int.self, forKey: .id)
        self.title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
        self.originTitle = try container.decodeIfPresent(String.self, forKey: .originTitle) ?? ""
        self.overview = try container.decode(String.self, forKey: .overview)
        self.posterPath = try container.decodeIfPresent(String.self, forKey: .posterPath) ?? ""
        self.mediaType = try container.decodeIfPresent(String.self, forKey: .mediaType)
        self.adult = try container.decode(Bool.self, forKey: .adult)
        self.originLanguage = try container.decode(String.self, forKey: .originLanguage)
        self.genreIds = try container.decode([Int].self, forKey: .genreIds)
        self.popularity = try container.decode(Double.self, forKey: .popularity)
        self.releaseDate = try container.decodeIfPresent(String.self, forKey: .releaseDate) ?? ""
        self.video = try container.decodeIfPresent(Bool.self, forKey: .video) ?? false
        self.voteAverage = try container.decode(Double.self, forKey: .voteAverage)
        self.voteCount = try container.decode(Int.self, forKey: .voteCount)
    }
}
