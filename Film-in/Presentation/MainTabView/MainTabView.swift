//
//  MainTabView.swift
//  Film-in
//
//  Created by Minjae Kim on 9/25/24.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView(
                viewModel: HomeViewModel(
                    homeService: DefaultHomeService(
                        tmdbRepository: DefaultTMDBRepository.shared,
                        databaseRepository: RealmRepository.shared
                    ),
                    networkMonitor: NetworkMonitor.shared
                )
            )
                .tabItem {
                    Image("home")
                    Text("HOME")
                }
            
//            Text("done")
//                .tabItem {
//                    Image("search")
//                    Text("SEARCH")
//                }
            
            MyView(
                viewModel: MyViewModel(
                    myViewService: DefaultMyViewService(
                        databaseRepository: RealmRepository.shared,
                        localNotificationManager: DefaultLocalNotificationManager.shared,
                        calendarManager: DefaultCalendarManager()
                    )
                )
            )
                .tabItem {
                    Image("movie")
                    Text("MY")
                }
        }
        .tint(.app)
    }
}
