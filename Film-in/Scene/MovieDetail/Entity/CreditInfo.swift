//
//  CreditInfo.swift
//  Film-in
//
//  Created by Minjae Kim on 9/27/24.
//

import Foundation

struct CreditInfo: Hashable, Identifiable {
    let id: Int
    let name: String
    let profilePath: String
    let role: String
}
