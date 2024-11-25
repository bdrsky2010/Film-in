//
//  MovieListQuery.swift
//  Film-in
//
//  Created by Minjae Kim on 9/29/24.
//

import Foundation

struct MovieListQuery {
    let movieId: Int?
    let language: String
    let page: Int
    let region: String
    var withGenres: String?
    
    init(
        movieId: Int? = nil,
        language: String,
        page: Int,
        region: String,
        withGenres: String? = nil
    ) {
        self.movieId = movieId
        self.language = language
        self.page = page
        self.region = region
        self.withGenres = withGenres
    }
}
