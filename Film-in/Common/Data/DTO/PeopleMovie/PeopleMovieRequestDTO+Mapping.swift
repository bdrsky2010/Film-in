//
//  PeopleMovieRequestDTO+Mapping.swift
//  Film-in
//
//  Created by Minjae Kim on 9/30/24.
//

import Foundation

struct PeopleMovieRequestDTO: Encodable, RequestParametable {
    let language: String
}
