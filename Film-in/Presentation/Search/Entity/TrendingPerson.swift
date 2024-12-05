//
//  TrendingPerson.swift
//  Film-in
//
//  Created by Minjae Kim on 12/5/24.
//

import Foundation

struct TrendingPerson: Hashable, Identifiable {
    let id = UUID()
    let _id: Int
    let name: String
    let profilePath: String
}
