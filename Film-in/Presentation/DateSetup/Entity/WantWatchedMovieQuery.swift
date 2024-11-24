//
//  WantWatchedMovieQuery.swift
//  Film-in
//
//  Created by Minjae Kim on 10/1/24.
//

import Foundation

struct WantWatchedMovieQuery {
    let movieId: Int
    let title: String
    let backdrop: String
    let poster: String
    let date: Date
    let type: DateSetupType
    let isAlarm: Bool
}
