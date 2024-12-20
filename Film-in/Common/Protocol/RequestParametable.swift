//
//  Parametable.swift
//  Film-in
//
//  Created by Minjae Kim on 12/9/24.
//

import Foundation

// MARK: 네트워크 요청 시, Parameter로 데이터 변환 가능
protocol RequestParametable where Self: Encodable {
    var asParameters: [String: Any] { get }
}

extension RequestParametable {
    var asParameters: [String : Any] {
        return JSONEncoder.toDictionary(self)
    }
}
