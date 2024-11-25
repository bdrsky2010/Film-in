//
//  MovieInfo.swift
//  Film-in
//
//  Created by Minjae Kim on 9/27/24.
//

import Foundation

struct MovieInfo {
    let id: Int
    let title: String
    let overview: String
    let genres: [MovieGenre]
    let runtime: Int
    let rating: Double
    let releaseDate: String
    
    var isReleased: Bool {
        let dateFormatter = Date.dateFormatter
        dateFormatter.locale = .init(identifier: "ko-KR")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let today = dateFormatter.string(from: Date())
        return releaseDate > today
    }
}
