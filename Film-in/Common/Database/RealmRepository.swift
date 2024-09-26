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
}
