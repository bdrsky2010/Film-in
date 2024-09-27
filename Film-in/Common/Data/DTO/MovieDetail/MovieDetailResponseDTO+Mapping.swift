//
//  MovieDetailResponseDTO.swift
//  Film-in
//
//  Created by Minjae Kim on 9/23/24.
//

import Foundation

struct MovieDetailResponseDTO: Decodable {
    struct Genre: Decodable {
        let id: Int
        let name: String
    }
    
    struct ProductionCompany: Decodable {
        let id: Int
        let logoPath: String
        let name: String
        let originCountry: String
        
        enum CodingKeys: String, CodingKey {
            case id
            case logoPath = "logo_path"
            case name
            case originCountry = "origin_country"
        }
    }
    
    let adult: Bool
    let backdropPath: String // backdrop_path
    let budget: Int
    let genres: [Genre]
    let homepage: String
    let id: Int
    let imdbId: String // imdb_id
    let originCountry: [String] // origin_country
    let originalLanguage: String // original_language
    let originalTitle: String // original_title
    let overview: String
    let popularity: Double
    let posterPath: String?
    let productionCompanies: [ProductionCompany]?
    let releaseDate: String // release_date
    let runtime: Int
    let status: String
    let tagline: String
    let title: String
    let video: Bool
    let voteAverage: Double // vote_average
    let voteCount: Int // vote_count
    
    enum CodingKeys: String, CodingKey {
        case adult
        case backdropPath = "backdrop_path"
        case budget
        case genres
        case homepage
        case id
        case imdbId = "imdb_id"
        case originCountry = "origin_country"
        case originalLanguage = "original_language"
        case originalTitle = "original_title"
        case overview
        case popularity
        case posterPath
        case productionCompanies
        case releaseDate = "release_date"
        case runtime
        case status
        case tagline
        case title
        case video
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }
}

extension MovieDetailResponseDTO {
    var toEntity: MovieInfo {
        return MovieInfo(
            id: self.id,
            title: self.title,
            overview: self.overview,
            genres: self.genres
                .map {
                    MovieGenre(id: $0.id, name: $0.name)
                },
            runtime: self.runtime,
            rating: self.voteAverage,
            releaseDate: self.releaseDate
        )
    }
}
