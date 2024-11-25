//
//  MyViewFactory.swift
//  Film-in
//
//  Created by Minjae Kim on 11/25/24.
//

import SwiftUI

enum MyFactory {
    static func makeView() -> some View {
        MyView(
            viewModel: MyViewModel(
                myViewService: DefaultMyViewService(
                    databaseRepository: RealmRepository.shared,
                    localNotificationManager: DefaultLocalNotificationManager.shared,
                    calendarManager: DefaultCalendarManager()
                )
            )
        )
    }
}
