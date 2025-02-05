//
//  RealmRepository.swift
//  Film-in
//
//  Created by Minjae Kim on 9/25/24.
//

import Foundation
import RealmSwift

protocol DatabaseRepository: AnyObject {
    func createUser()
    func appendLikeGenres(genres: Set<MovieGenre>)
    func appendWantOrWatchedMovie(data: WantWatchedMovieRequestDTO)
    func deleteMovie(movieId: Int)
    func printFilePath()
    
    var realm: Realm { get }
    var user: UserTable? { get }
}

final class RealmRepository: DatabaseRepository {
    static let shared = RealmRepository()
    
    var realm: Realm { try! Realm() }
    
    var user: UserTable? { realm.objects(UserTable.self).first }
    
    func createUser() {
        do {
            try realm.write {
                realm.create(UserTable.self, value: UserTable())
            }
        } catch {
            // TODO: Create User Error Handling
        }
    }
    
    func appendLikeGenres(genres: Set<MovieGenre>) {
        do {
            try realm.write {
                user?.selectedGenreIds.append(objectsIn: genres.map { $0.id })
            }
        } catch {
            // TODO: Update Genres Error Handling
        }
    }
    
    func appendWantOrWatchedMovie(data: WantWatchedMovieRequestDTO) {
        guard let user else { return }
        do {
            try realm.write {
                if let movie = realm.objects(MovieTable.self).first(where: { $0.id == data.movieId }) {
                    realm.delete(movie)
                }
                let newMovie = MovieTable(
                    id: data.movieId,
                    title: data.title,
                    backdrop: data.backdrop,
                    poster: data.poster,
                    status: data.type == .want ? (data.isAlarm ? .wantWithNotification : .want) : .watched,
                    date: data.date
                )
                
                if data.type == .watched {
                    user.watchedMovies.append(newMovie)
                    user.watchedMovies.sort(by: { $0.date < $1.date }) // 내림차순 정렬
                } else {
                    user.wantMovies.append(newMovie)
                    user.wantMovies.sort(by: { $0.date < $1.date }) // 내림차순 정렬
                }
            }
        } catch {
            
        }
    }
    
    func deleteMovie(movieId: Int) {
        do {
            try realm.write {
                guard let movie = realm.objects(MovieTable.self).first(where: { $0.id == movieId }) else { return }
                realm.delete(movie)
            }
        } catch {
            
        }
    }
    
    func printFilePath() {
        print(Realm.Configuration.defaultConfiguration.fileURL ?? "")
    }
}
