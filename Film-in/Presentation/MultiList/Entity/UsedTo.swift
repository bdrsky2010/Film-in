//
//  UsedTo.swift
//  Film-in
//
//  Created by Minjae Kim on 12/13/24.
//

import Foundation

enum UsedTo {
    case nowPlaying
    case upcoming
    case recommend
    case similar(_ movieId: Int)
    case searchMovie(_ query: String)
    case searchPerson(_ query: String)
    
    var title: String {
        switch self {
        case .nowPlaying: return "nowPlaying".localized
        case .upcoming: return "upcoming".localized
        case .recommend: return "recommend".localized
        case .similar: return "simliar".localized
        case .searchMovie: return ""
        case .searchPerson: return ""
        }
    }
}
