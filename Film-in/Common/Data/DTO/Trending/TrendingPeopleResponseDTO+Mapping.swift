//
//  TrendingPeopleResponseDTO.swift
//  Film-in
//
//  Created by Minjae Kim on 12/5/24.
//

import Foundation

struct TrendingPeopleResponseDTO: Decodable {
    let results: [TMDBPersonResponseDTO]
}

extension TrendingPeopleResponseDTO {
    func toEntity() -> [TrendingPerson] {
        return results
            .filter {
                $0.department == "Acting"
            }
            .map {
                TrendingPerson(
                    _id: $0.id,
                    name: $0.name,
                    profilePath: $0.profilePath
                )
            }
    }
}
