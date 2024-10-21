//
//  PersonDetailViewModel.swift
//  Film-in
//
//  Created by Minjae Kim on 9/30/24.
//

import Foundation
import Combine

final class PersonDetailViewModel: BaseObject, ViewModelType {
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
            .sink { [weak self] in
                guard let self else { return }
                fetchPersonInfo()
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
    private func fetchPersonInfo() {
        guard networkMonitor.networkType != .notConnect else {
            output.networkConnect = false
            return
        }
        output.networkConnect = true
        
        fetchPersonDetail()
        fetchPersonMovie()
    }
    
    private func fetchPersonDetail() {
        let query = PersonQuery(language: "longLanguageCode".localized, personId: personId)
        let publisher = personDetailService.fetchPersonDetail(query: query)
        publisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                guard let self else { return }
                switch result {
                case .success(let personDetail):
                    output.personDetail = personDetail
                case .failure(_):
                    if !output.isShowAlert { output.isShowAlert = true }
                }
            }
            .store(in: &cancellable)
    }
    
    private func fetchPersonMovie() {
        let query = PersonQuery(language: "longLanguageCode".localized, personId: personId)
        let publisher = personDetailService.fetchPersonMovie(query: query)
        publisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                guard let self else { return }
                switch result {
                case .success(let personMovie):
                    output.personMovie = personMovie
                case .failure(_):
                    if !output.isShowAlert { output.isShowAlert = true }
                }
            }
            .store(in: &cancellable)
    }
}
