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
    
    var user: UserTable? { get }
}

final class RealmRepository: DatabaseRepository {
    static let shared = RealmRepository()
    
    private let realm = try! Realm()
    
    var user: UserTable? { realm.objects(UserTable.self).first }
    
    private init() { }
    
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
                } else {
                    user.wantMovies.append(newMovie)
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
