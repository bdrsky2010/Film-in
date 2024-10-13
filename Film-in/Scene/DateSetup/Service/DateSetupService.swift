//
//  DateSetupService.swift
//  Film-in
//
//  Created by Minjae Kim on 10/1/24.
//

import Foundation
import Combine

enum NotificationError: Error {
    case failure
}

protocol DateSetupService: AnyObject {
    func requestPermission() -> Future<Result<Void, NotificationError>, Never>
    func registPushAlarm(movie: (id: Int, title: String), date: Date) -> Future<Result<Void, NotificationError>, Never>
    func goToSetting()
    func saveWantOrWatchedMovie(query: WantWatchedMovieQuery)
}

final class DefaultDateSetupService: BaseObject {
    private let localNotificationManager: LocalNotificationManager
    private let databaseRepository: DatabaseRepository
    
    init(
        localNotificationManager: LocalNotificationManager,
        databaseRepository: DatabaseRepository
    ) {
        self.localNotificationManager = localNotificationManager
        self.databaseRepository = databaseRepository
    }
}

extension DefaultDateSetupService: DateSetupService {
    func requestPermission() -> Future<Result<Void, NotificationError>, Never> {
        return Future { promise in
            Task { [weak self] in
                guard let self else { return }
                do {
                    try await localNotificationManager.requestPermission()
                    promise(.success(.success(())))
                } catch {
                    promise(.success(.failure(.failure)))
                }
            }
        }
    }
    
    func registPushAlarm(movie: (id: Int, title: String), date: Date) -> Future<Result<Void, NotificationError>, Never> {
        return Future { promise in
            Task { [weak self] in
                guard let self else { return }
                do {
                    try await localNotificationManager.schedule(movie: movie, date: date)
                    promise(.success(.success(())))
                } catch {
                    promise(.success(.failure(.failure)))
                }
            }
        }
    }
    
    func goToSetting() {
        localNotificationManager.moveToSettings()
    }
    
    func saveWantOrWatchedMovie(query: WantWatchedMovieQuery) {
        let requestDTO = WantWatchedMovieRequestDTO(
            movieId: query.movieId,
            title: query.title,
            backdrop: query.backdrop,
            poster: query.poster,
            date: query.date,
            type: query.type,
            isAlarm: query.isAlarm
        )
        
        databaseRepository.appendWantOrWatchedMovie(data: requestDTO)
    }
}
