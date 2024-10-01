//
//  UserTable.swift
//  Film-in
//
//  Created by Minjae Kim on 9/25/24.
//

import Foundation
import RealmSwift

enum MovieWatchStatus: Int, PersistableEnum {
    case wantWithNotification
    case want
    case watched
}

final class UserTable: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var selectedGenreIds: List<Int>
    @Persisted var wantMovies: List<MovieTable>
    @Persisted var watchedMovies: List<MovieTable>
    
    convenience init(
        selectedGenreIds: List<Int>,
        wantMovies: List<MovieTable> = List<MovieTable>(),
        watchedMovies: List<MovieTable> = List<MovieTable>()
    ) {
        self.init()
        self.selectedGenreIds = selectedGenreIds
        self.wantMovies = wantMovies
        self.watchedMovies = watchedMovies
    }
}

final class MovieTable: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: Int
    @Persisted var title: String
    @Persisted var backdrop: String
    @Persisted var poster: String
    @Persisted var status: MovieWatchStatus
    @Persisted var date: Date
    
    convenience init(id: Int, title: String, backdrop: String, poster: String, status: MovieWatchStatus, date: Date) {
        self.init()
        self.id = id
        self.title = title
        self.backdrop = backdrop
        self.poster = poster
        self.status = status
        self.date = date
    }
}
