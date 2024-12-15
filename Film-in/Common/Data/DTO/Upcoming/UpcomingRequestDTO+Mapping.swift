//
//  UpcomingRequestDTO+Mapping.swift
//  Film-in
//
//  Created by Minjae Kim on 9/21/24.
//

import Foundation

struct UpcomingRequestDTO: Encodable, RequestParametable {
    let language: String
    let page: Int
    let region: String
}
