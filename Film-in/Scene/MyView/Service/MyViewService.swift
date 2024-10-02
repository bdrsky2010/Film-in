//
//  MyViewService.swift
//  Film-in
//
//  Created by Minjae Kim on 10/2/24.
//

import Foundation

protocol MyViewService: AnyObject {
    func requestDeleteMovie(movieId: Int)
}

final class DefaultMyViewService: MyViewService {
    private let databaseRepository: DatabaseRepository
    private let localNotificationManager: LocalNotificationManager
    
    init(
        databaseRepository: DatabaseRepository,
        localNotificationManager: LocalNotificationManager
    ) {
        self.databaseRepository = databaseRepository
        self.localNotificationManager = localNotificationManager
    }
    
    func requestDeleteMovie(movieId: Int) {
        databaseRepository.deleteMovie(movieId: movieId)
        
        Task {
            await removePendingNotification(movieId: movieId)
        }
    }
    
    private func removePendingNotification(movieId: Int) async {
        do {
            try await localNotificationManager.removeNotification(movieId: movieId)
        } catch {
            print(error)
        }
    }
}
