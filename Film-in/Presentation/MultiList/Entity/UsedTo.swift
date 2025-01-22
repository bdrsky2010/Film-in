//
//  UsedTo.swift
//  Film-in
//
//  Created by Minjae Kim on 12/13/24.
//

import SwiftUI

enum UsedTo: Hashable {
    case nowPlaying
    case upcoming
    case recommend
    case similar(_ movieId: Int)
    case searchMovie(_ query: String)
    case searchPerson(_ query: String)
    
    var title: LocalizedStringKey {
        switch self {
        case .nowPlaying: return "nowPlaying"
        case .upcoming: return "upcoming"
        case .recommend: return "recommend"
        case .similar: return "similar"
        case .searchMovie: return ""
        case .searchPerson: return ""
        }
    }
}
