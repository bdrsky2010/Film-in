//
//  Coordinator.swift
//  Film-in
//
//  Created by Minjae Kim on 1/21/25.
//

import SwiftUI

enum AppRoute: Hashable {
    case home
    case search
    case movieDetail(_ movieID: Int)
    case personDetail(_ personID: Int)
    case myView
    case seeMore(_ usedTo: UsedTo)
}

enum Sheet {
    case dateSetup(_ movie: MovieData, _ type: DateSetupType)
}

protocol CoordinatorProtocol: AnyObject {
    var navigationPath: NavigationPath { get }
    var sheet: Sheet? { get }
    
    func push(_ view: AppRoute)
    func pop()
    func popToRoot()
    func presentSheet(_ sheet: Sheet)
    func dismissSheet()
}

final class Coordinator: ObservableObject {
    @Published private(set) var navigationPath = NavigationPath()
    @Published private(set) var sheet: Sheet?
}

extension Coordinator: CoordinatorProtocol {
    func push(_ view: AppRoute) {
        navigationPath.append(view)
    }
    
    func pop() {
        navigationPath.removeLast()
    }
    
    func popToRoot() {
        navigationPath.removeLast(navigationPath.count)
    }
    
    func presentSheet(_ sheet: Sheet) {
        self.sheet = sheet
    }
    
    func dismissSheet() {
        sheet = nil
    }
}
