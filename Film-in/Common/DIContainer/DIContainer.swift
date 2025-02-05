//
//  DIContainer.swift
//  Film-in
//
//  Created by Minjae Kim on 1/19/25.
//

import Foundation

protocol DIContainer where Self: ObservableObject {
    func makeGenreSelectViewModel() -> GenreSelectViewModel
    func makeHomeViewModel() -> HomeViewModel
    func makeSearchViewModel() -> SearchViewModel
    func makeSearchResultViewModel() -> SearchResultViewModel
    func makeMyViewModel() -> MyViewModel
    func makeMovieDetailViewModel(movieID: Int) -> MovieDetailViewModel
    func makePersonDetailViewModel(personID: Int) -> PersonDetailViewModel
    func makeDateSetupViewModel(movie: MovieData, type: DateSetupType) -> DateSetupViewModel
    func makeMultiListViewModel(usedTo: UsedTo) -> MultiListViewModel
}

final class DefaultDIContainer: ObservableObject {
    private let networkManager: NetworkManager
    private let networkMonitor: NetworkMonitor
    private let tmdbRepository: TMDBRepository
    private let databaseRepository: DatabaseRepository
    private let localNotificationManager: LocalNotificationManager
    
    init(
        networkManager: NetworkManager = DefaultNetworkManager(),
        networkMonitor: NetworkMonitor = NetworkMonitor(),
        databaseRepository: DatabaseRepository = RealmRepository(),
        localNotificationManager: LocalNotificationManager = DefaultLocalNotificationManager()
    ) {
        self.networkManager = networkManager
        self.networkMonitor = networkMonitor
        self.tmdbRepository = DefaultTMDBRepository(networkManager: networkManager)
        self.databaseRepository = databaseRepository
        self.localNotificationManager = localNotificationManager
    }
}

extension DefaultDIContainer: DIContainer {
    func makeGenreSelectViewModel() -> GenreSelectViewModel {
        let genreSelectService = DefaultGenreSelectService(
            tmdbRepository: tmdbRepository,
            databaseRepository: databaseRepository
        )
        return GenreSelectViewModel(
            genreSelectService: genreSelectService,
            networkMonitor: networkMonitor
        )
    }
    
    func makeHomeViewModel() -> HomeViewModel {
        let homeService = DefaultHomeService(
            tmdbRepository: tmdbRepository,
            databaseRepository: databaseRepository
        )
        return HomeViewModel(homeService: homeService, networkMonitor: networkMonitor)
    }
    
    func makeSearchViewModel() -> SearchViewModel {
        let searchService = DefaultSearchService(tmdbRepository: tmdbRepository)
        return SearchViewModel(searchSerivce: searchService, networkMonitor: networkMonitor)
    }
    
    func makeSearchResultViewModel() -> SearchResultViewModel {
        let searchResultService = DefaultSearchResultService(tmdbRepository: tmdbRepository)
        return SearchResultViewModel(networkMonitor: networkMonitor, searchResultService: searchResultService)
    }
    
    func makeMyViewModel() -> MyViewModel {
        let myViewService = DefaultMyViewService(
            databaseRepository: databaseRepository,
            localNotificationManager: localNotificationManager,
            calendarManager: DefaultCalendarManager()
        )
        return MyViewModel(myViewService: myViewService)
    }
    
    func makeMovieDetailViewModel(movieID: Int) -> MovieDetailViewModel {
        let movieDetailService = DefaultMovieDetailService(
            tmdbRepository: tmdbRepository,
            databaseRepository: databaseRepository
        )
        
        return MovieDetailViewModel(
            movieDetailService: movieDetailService,
            networkMonitor: networkMonitor,
            movieId: movieID
        )
    }
    
    func makePersonDetailViewModel(personID: Int) -> PersonDetailViewModel {
        let personDetailService = DefaultPersonDetailService(
            tmdbRepository: tmdbRepository,
            databaseRepository: databaseRepository
        )
        return PersonDetailViewModel(
            personDetailService: personDetailService,
            networkMonitor: networkMonitor,
            personId: personID
        )
    }
    
    func makeDateSetupViewModel(movie: MovieData, type: DateSetupType) -> DateSetupViewModel {
        let dateSetupService = DefaultDateSetupService(
            localNotificationManager: localNotificationManager,
            databaseRepository: databaseRepository
        )
        return DateSetupViewModel(
            dateSetupService: dateSetupService,
            movie: movie,
            type: type
        )
    }
    
    func makeMultiListViewModel(usedTo: UsedTo) -> MultiListViewModel {
        let multiListService = DefaultMultiListService(
            tmdbRepository: tmdbRepository,
            databaseRepository: databaseRepository
        )
        return MultiListViewModel(
            multiListService: multiListService,
            networkMonitor: networkMonitor,
            usedTo: usedTo
        )
    }
}
