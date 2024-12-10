//
//  SearchMovieRequestDTO+Mapping.swift
//  Film-in
//
//  Created by Minjae Kim on 9/23/24.
//

import Foundation

struct SearchMovieRequestDTO: Encodable, RequestParametable {
    let query: String
    let language: String
    let page: Int
    let region: String
}
