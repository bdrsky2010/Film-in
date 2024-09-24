//
//  NetworkMonitor.swift
//  Film-in
//
//  Created by Minjae Kim on 9/24/24.
//

import Foundation
import Network

enum NetworkType {
    case wifi
    case cellular
    case notConnect
}

final class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()
    
    private let monitor = NWPathMonitor(prohibitedInterfaceTypes: [.wifi, .cellular])
    
    @Published var networkType: NetworkType = .notConnect
    
    private init() {
        monitor.start(queue: .global())
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                if path.usesInterfaceType(.wifi) {
                    networkType = .wifi
                } else if path.usesInterfaceType(.cellular) {
                    networkType = .cellular
                } else {
                    networkType = .notConnect
                }
            }
        }
    }
}
