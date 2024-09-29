//
//  MovieSimilar.swift
//  Film-in
//
//  Created by Minjae Kim on 9/27/24.
//

import Foundation

struct MovieSimilar {
    struct Movie: Hashable, Identifiable {
        let id: Int
        let title: String
        let poster: String
    }
    
    let page: Int
    let totalPage: Int
    let movies: [Movie]
}
