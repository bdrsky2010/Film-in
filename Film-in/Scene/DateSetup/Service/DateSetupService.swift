//
//  DateSetupService.swift
//  Film-in
//
//  Created by Minjae Kim on 10/1/24.
//

import Foundation

protocol DateSetupService: AnyObject {
    func requestPermission() async throws
    func registPushAlarm(movie: (id: Int, title: String), date: Date) async throws
    func goToSetting()
    func saveWantOrWatchedMovie(query: WantWatchedMovieQuery)
}

final class DefaultDateSetupService {
    private let localNotificationManager: LocalNotificationManager
    private let databaseRepository: DatabaseRepository
    
    init(
        localNotificationManager: LocalNotificationManager,
        databaseRepository: DatabaseRepository
    ) {
        self.localNotificationManager = localNotificationManager
        self.databaseRepository = databaseRepository
    }
    
    deinit {
        print("\(String(describing: self)) is deinit")
    }
}

extension DefaultDateSetupService: DateSetupService {
    func requestPermission() async throws {
        try await localNotificationManager.requestPermission()
    }
    
    func registPushAlarm(movie: (id: Int, title: String), date: Date) async throws {
        try await localNotificationManager.schedule(movie: movie, date: date)
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
