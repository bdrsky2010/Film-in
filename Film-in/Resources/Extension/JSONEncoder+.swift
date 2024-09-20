//
//  JSONEncoder+.swift
//  Film-in
//
//  Created by Minjae Kim on 9/20/24.
//

import Foundation

extension JSONEncoder {
    private static let encoder = JSONEncoder()
    
    static func toDictionary<T: Encodable>(_ dto: T) -> [String: Any] {
        guard let data = try? encoder.encode(dto) else { return [:] }
        guard let parameters = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return [:] }
        return parameters
    }
}
