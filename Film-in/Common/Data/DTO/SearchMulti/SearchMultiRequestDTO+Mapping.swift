//
//  SearchMultiRequestDTO+Mapping.swift
//  Film-in
//
//  Created by Minjae Kim on 12/9/24.
//

import Foundation

struct SearchMultiRequestDTO: Encodable, RequestParametable {
    let query: String
    let language: String
}
