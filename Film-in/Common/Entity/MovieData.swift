//
//  MovieData.swift
//  Film-in
//
//  Created by Minjae Kim on 11/25/24.
//

import Foundation

struct MovieData: Hashable, Identifiable {
    let id = UUID()
    let _id: Int
    let title: String
    let poster: String
    let backdrop: String
}
