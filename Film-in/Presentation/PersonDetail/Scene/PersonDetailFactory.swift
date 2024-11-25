//
//  PersonDetailFactory.swift
//  Film-in
//
//  Created by Minjae Kim on 11/25/24.
//

import SwiftUI

enum PersonDetailFactory {
    static func makeView(personId: Int) -> some View {
        PersonDetailView(
            viewModel: PersonDetailViewModel(
                personDetailService: DefaultPersonDetailService(
                    tmdbRepository: DefaultTMDBRepository.shared,
                    databaseRepository: RealmRepository.shared
                ),
                networkMonitor: NetworkMonitor.shared,
                personId: personId
            )
        )
    }
}
