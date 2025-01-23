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
    case movieDetail(_ movie: MovieData, _ size: CGSize)
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
    @Published private var diContainer = DefaultDIContainer()
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

extension Coordinator {
    @ViewBuilder
    func bulid(_ view: AppRoute) -> some View {
        switch view {
        case .home:
            HomeView(viewModel: diContainer.makeHomeViewModel())
        case .search:
            SearchView(viewModel: diContainer.makeSearchViewModel())
        case .movieDetail(let movie, let size):
            MovieDetailView(viewModel: diContainer.makeMovieDetailViewModel(movieID: movie._id), movie: movie, size: size)
        case .personDetail(let personID):
            PersonDetailView(viewModel: diContainer.makePersonDetailViewModel(personID: personID))
        case .myView:
            MyView(viewModel: diContainer.makeMyViewModel())
        case .seeMore(let usedTo):
            SeeMoreView(viewModel: diContainer.makeMultiListViewModel(usedTo: usedTo))
        }
    }
    
    @ViewBuilder
    func buildSheet(_ sheet: Sheet) -> some View {
        switch sheet {
        case .dateSetup(let movie, let type):
            DateSetupView(viewModel: diContainer.makeDateSetupViewModel(movie: movie, type: type))
        }
    }
}
