//
//  TMDBMovieResponseDTO.swift
//  Film-in
//
//  Created by Minjae Kim on 9/21/24.
//

import Foundation

struct TMDBMovieResponseDTO: Decodable {
    let backdropPath: String? // upcoming에서 없을 수 있음
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
    let voteAvg: Double
    let voteCnt: Int
    
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
        case voteAvg = "vote_average"
        case voteCnt = "vote_count"
    }
}
