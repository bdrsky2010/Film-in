//
//  MainTabView.swift
//  Film-in
//
//  Created by Minjae Kim on 9/25/24.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var diContainer: DefaultDIContainer
    
    var body: some View {
        TabView {
            HomeView(viewModel: diContainer.makeHomeViewModel())
                .tabItem {
                    Image("home")
                    Text(verbatim: "HOME")
                }
            
            SearchView(viewModel: diContainer.makeSearchViewModel())
                .tabItem {
                    Image("search")
                    Text(verbatim: "SEARCH")
                }
            
            MyView(viewModel: diContainer.makeMyViewModel())
                .tabItem {
                    Image("movie")
                    Text(verbatim: "MY")
                }
        }
        .tint(.app)
    }
}
