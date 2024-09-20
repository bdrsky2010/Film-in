//
//  GenreResponseDTO.swift
//  Film-in
//
//  Created by Minjae Kim on 9/20/24.
//

import Foundation

struct GenreResponseDTO: Decodable {
    struct Genre: Decodable {
        let id: Int
        let name: String
    }
    
    let genres: [Genre]
}
