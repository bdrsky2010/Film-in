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
    
    struct Movie: Hashable, Identifiable {
        let id = UUID()
        let _id: Int
        let title: String
        let poster: String
        let backdrop: String
    }
    
    let period: Period?
    let page: Int?
    let totalPage: Int?
    var movies: [Movie]
    
    init(
        period: Period? = nil,
        page: Int? = nil,
        totalPage: Int? = nil,
        movies: [Movie]
    ) {
        self.period = period
        self.page = page
        self.totalPage = totalPage
        self.movies = movies
    }
}
