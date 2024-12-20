//
//  GenreRequestDTO.swift
//  Film-in
//
//  Created by Minjae Kim on 9/20/24.
//

import Foundation

struct GenreRequestDTO: Encodable, RequestParametable {
    let language: String
}
