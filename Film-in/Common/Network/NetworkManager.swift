//
//  NetworkManager.swift
//  Film-in
//
//  Created by Minjae Kim on 9/20/24.
//

import Foundation
import Moya

protocol NetworkManager: AnyObject {
    func request<T: Decodable>(_ case: TMDBRouter, of type: T.Type) async
}

final class DefaultNetworkManager: NetworkManager {
    static let shared = DefaultNetworkManager()
    
    private let provider = MoyaProvider<TMDBRouter>()
    
    private init() { }
    
    func request<T: Decodable>(_ tmdbAPI: TMDBRouter, of type: T.Type) async {
        let result = await provider.request(tmdbAPI)
        print(result)
    }
}

extension MoyaProvider {
    func request(_ target: Target) async -> Result<Response, MoyaError> {
            await withCheckedContinuation { continuation in
                self.request(target) { result in
                    continuation.resume(returning: result)
                }
            }
        }
}
