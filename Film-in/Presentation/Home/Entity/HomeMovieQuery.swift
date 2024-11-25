//
//  DiscoverQuery.swift
//  Film-in
//
//  Created by Minjae Kim on 9/26/24.
//

import Foundation

// NowPlaying, Upcoming, Discover use Same Query
struct HomeMovieQuery {
    let language: String
    let page: Int
    let region: String
    var withGenres: String?
    
    init(
        language: String,
        page: Int,
        region: String,
        withGenres: String? = nil
    ) {
        self.language = language
        self.page = page
        self.region = region
        self.withGenres = withGenres
    }
}
