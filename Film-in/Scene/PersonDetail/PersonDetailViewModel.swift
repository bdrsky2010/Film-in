//
//  PersonDetailViewModel.swift
//  Film-in
//
//  Created by Minjae Kim on 9/30/24.
//

import Foundation
import Combine

final class PersonDetailViewModel: BaseViewModel, ViewModelType {
    private let personDetailService: PersonDetailService
    private let networkMonitor: NetworkMonitor
    private let personId: Int
    
    @Published var output = Output()
    
    var input = Input()
    var cancellable = Set<AnyCancellable>()
    
    init(
        personDetailService: PersonDetailService,
        networkMonitor: NetworkMonitor,
        personId: Int
    ) {
        self.personDetailService = personDetailService
        self.networkMonitor = networkMonitor
        self.personId = personId
        super.init()
        transform()
    }
}

extension PersonDetailViewModel {
    struct Input {
        var viewOnTask = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        var networkConnect = true
        var isShowAlert = false
        var personDetail = PersonDetail(id: 0, name: "", birthday: "", placeOfBirth: "", profilePath: "")
        var personMovie = PersonMovie(id: 0, movies: [])
    }
    
    func transform() {
        input.viewOnTask
            .sink {
                Task { [weak self] in
                    guard let self else { return }
                    await fetchPersonInfo()
                }
            }
            .store(in: &cancellable)
    }
}

extension PersonDetailViewModel {
    enum Action {
        case viewOnTask
        case refresh
    }
    
    func action(_ action: Action) {
        switch action {
        case .viewOnTask:
            input.viewOnTask.send(())
        case .refresh:
            input.viewOnTask.send(())
        }
    }
}

extension PersonDetailViewModel {
    @MainActor
    private func fetchPersonInfo() async {
        guard networkMonitor.networkType != .notConnect else {
            output.networkConnect = false
            return
        }
        output.networkConnect = true
        
        do {
            try await fetchPersonDetail()
            try await fetchPersonMovie()
        } catch {
            output.isShowAlert = true
        }
    }
    
    @MainActor
    private func fetchPersonDetail() async throws {
        let query = PersonQuery(language: "longLanguageCode".localized, personId: personId)
        let result = await personDetailService.fetchPersonDetail(query: query)
        switch result {
        case .success(let success):
            output.personDetail = success
        case .failure(let failure):
            print(#function, failure)
            throw failure
        }
    }
    
    @MainActor
    private func fetchPersonMovie() async throws {
        let query = PersonQuery(language: "longLanguageCode".localized, personId: personId)
        let result = await personDetailService.fetchPersonMovie(query: query)
        switch result {
        case .success(let success):
            output.personMovie = success
        case .failure(let failure):
            print(#function, failure)
            throw failure
        }
    }
}
