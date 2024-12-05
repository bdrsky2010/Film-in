//
//  AppStorageDictionary.swift
//  Film-in
//
//  Created by Minjae Kim on 12/5/24.
//

import Foundation

extension Dictionary: RawRepresentable where Key: Codable, Value: Codable {
    public typealias RawValue = String
    
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let value = try? JSONDecoder().decode(Dictionary.self, from: data) else {
            return nil
        }
        self = value
    }
    
    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let value = String(data: data, encoding: .utf8) else {
            return "{}"
        }
        return value
    }
}
