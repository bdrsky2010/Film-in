//
//  DiscoverQuery.swift
//  Film-in
//
//  Created by Minjae Kim on 9/26/24.
//

import Foundation

// NowPlaying, Upcoming, Discover use Same Query
struct HomeMovieQuery {
    let page: Int
    var withGenres: String?
    
    init(
        page: Int,
        withGenres: String? = nil
    ) {
        self.page = page
        self.withGenres = withGenres
    }
}
