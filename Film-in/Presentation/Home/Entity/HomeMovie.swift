//
//  HomeMovie.swift
//  Film-in
//
//  Created by Minjae Kim on 9/26/24.
//

import Foundation

struct HomeMovie {
    struct Period {
        let minimum: String
        let maximum: String
    }
    
    let period: Period?
    let page: Int?
    let totalPage: Int?
    var movies: [MovieData]
    
    init(
        period: Period? = nil,
        page: Int? = nil,
        totalPage: Int? = nil,
        movies: [MovieData]
    ) {
        self.period = period
        self.page = page
        self.totalPage = totalPage
        self.movies = movies
    }
}
