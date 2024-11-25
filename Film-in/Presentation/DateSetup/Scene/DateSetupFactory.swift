//
//  DateSetupFactory.swift
//  Film-in
//
//  Created by Minjae Kim on 11/25/24.
//

import SwiftUI

enum DateSetupFactory {
    static func makeView(movie: MovieData, type: DateSetupType, isPresented: Binding<Bool>) -> some View {
        DateSetupView(
            viewModel: DateSetupViewModel(
                dateSetupService: DefaultDateSetupService(
                    localNotificationManager: DefaultLocalNotificationManager.shared,
                    databaseRepository: RealmRepository.shared
                ),
                movie: movie,
                type: type
            ),
            isPresented: isPresented
        )
    }
}
