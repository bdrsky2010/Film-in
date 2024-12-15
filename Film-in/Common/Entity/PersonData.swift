//
//  PersonData.swift
//  Film-in
//
//  Created by Minjae Kim on 12/10/24.
//

import Foundation

struct PersonData: Hashable, Identifiable {
    let id = UUID()
    let _id: Int
    let name: String
    let profile: String
}
