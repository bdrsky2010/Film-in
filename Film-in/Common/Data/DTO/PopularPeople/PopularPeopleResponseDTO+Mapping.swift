//
//  PopularPeopleResponseDTO+Mapping.swift
//  Film-in
//
//  Created by Minjae Kim on 12/5/24.
//

import Foundation

struct PopularPeopleResponseDTO: Decodable {
    let results: [TMDBPersonResponseDTO]
}

extension PopularPeopleResponseDTO {
    func toEntity() -> [PopularPerson] {
        return results
            .filter {
                $0.department == "Acting"
            }
            .map {
                PopularPerson(
                    _id: $0.id,
                    name: $0.name,
                    profilePath: $0.profilePath
                )
            }
    }
}
