//
//  PersonMovie.swift
//  Film-in
//
//  Created by Minjae Kim on 9/30/24.
//

import Foundation

struct PersonMovie {
    struct Movie: Hashable, Identifiable {
        let id: Int
        let title: String
        let poster: String
    }
    
    let id: Int
    let movies: [Movie]
}
