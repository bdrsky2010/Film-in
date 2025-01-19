//
//  DIContainer.swift
//  Film-in
//
//  Created by Minjae Kim on 1/19/25.
//

import Foundation

protocol DIContainer where Self: ObservableObject {
    func makeViewModel<ViewModel: ViewModelType>(what object: ViewModel.Type) -> ViewModel
}

final class DefaultDIContainer: ObservableObject {
    private let networkManager: NetworkManager
    private let networkMonitor: NetworkMonitor
    private let tmdbRepository: TMDBRepository
    private let databaseRepository: DatabaseRepository
    private let localNotificationManager: LocalNotificationManager
    
    init(
        networkManager: NetworkManager,
        networkMonitor: NetworkMonitor,
        tmdbRepository: TMDBRepository,
        databaseRepository: DatabaseRepository,
        localNotificationManager: LocalNotificationManager
    ) {
        self.networkManager = networkManager
        self.networkMonitor = networkMonitor
        self.tmdbRepository = tmdbRepository
        self.databaseRepository = databaseRepository
        self.localNotificationManager = localNotificationManager
    }
}

