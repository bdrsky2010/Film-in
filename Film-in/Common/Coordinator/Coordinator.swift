//
//  Coordinator.swift
//  Film-in
//
//  Created by Minjae Kim on 1/21/25.
//

import SwiftUI

enum AppRoute {
    case home
    case search
    case movieDetail
    case personDetail
    case myView
    case seeMore
}

enum Sheet {
    case dateSetup
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
