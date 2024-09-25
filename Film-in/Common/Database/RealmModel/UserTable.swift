//
//  UserTable.swift
//  Film-in
//
//  Created by Minjae Kim on 9/25/24.
//

import Foundation
import RealmSwift

final class UserTable: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var selectedGenreIds: List<Int>
    
    convenience init(selectedGenreIds: List<Int>) {
        self.init()
        self.selectedGenreIds = selectedGenreIds
    }
}
