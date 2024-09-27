//
//  MovieImage.swift
//  Film-in
//
//  Created by Minjae Kim on 9/27/24.
//

import Foundation

struct MovieImages{
    struct MovieImage: Hashable, Identifiable {
        let id = UUID()
        let ratio: Double
        let width: Int
        let height: Int
        let path: String
    }
    
    let backdrops: [MovieImage]
    let posterss: [MovieImage]
}
