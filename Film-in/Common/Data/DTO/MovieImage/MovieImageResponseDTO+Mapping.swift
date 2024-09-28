//
//  MovieImageResponseDTO.swift
//  Film-in
//
//  Created by Minjae Kim on 9/23/24.
//

import Foundation

struct MovieImageResponseDTO: Decodable {
    struct MovieImage: Decodable {
        let aspectRatio: Double
        let height: Int
        let filePath: String
        let voteAverage: Double
        let voteCount: Int
        let width: Int
        
        enum CodingKeys: String, CodingKey {
            case aspectRatio = "aspect_ratio"
            case height
            case filePath = "file_path"
            case voteAverage = "vote_average"
            case voteCount = "vote_count"
            case width
        }
    }
    
    let id: Int
    let backdrops: [MovieImage]
    let logos: [MovieImage]
    let posters: [MovieImage]
}

extension MovieImageResponseDTO {
    var toEntity: MovieImages {
        return MovieImages(
            backdrops: self.backdrops
                .map {
                    .init(ratio: $0.aspectRatio,
                          width: $0.width,
                          height: $0.height,
                          path: $0.filePath
                    )
                },
            posters: self.posters
                .map {
                    .init(ratio: $0.aspectRatio,
                          width: $0.width,
                          height: $0.height,
                          path: $0.filePath
                    )
                }
        )
    }
}
