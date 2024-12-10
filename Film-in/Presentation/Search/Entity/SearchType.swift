//
//  SearchType.swift
//  Film-in
//
//  Created by Minjae Kim on 12/9/24.
//

import Foundation

enum SearchType: CaseIterable, CustomStringConvertible {
    case movie, person
    
    var description: String {
        switch self {
        case .movie:  "MOVIE"
        case .person: "ACTOR"
        }
    }
}
