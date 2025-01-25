//
//  MainTabView.swift
//  Film-in
//
//  Created by Minjae Kim on 9/25/24.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var diContainer: DefaultDIContainer
    @StateObject private var homeCoordinator = Coordinator()
    @StateObject private var searchCoordinator = Coordinator()
    @StateObject private var myViewCoordinator = Coordinator()
    
    var body: some View {
        TabView {
            CoordinatorView(destination: .home)
                .tabItem {
                    Image("home")
                    Text(verbatim: "HOME")
                }
            
            SearchView(viewModel: diContainer.makeSearchViewModel())
                .environmentObject(searchCoordinator)
                .tabItem {
                    Image("search")
                    Text(verbatim: "SEARCH")
                }
            
            MyView(viewModel: diContainer.makeMyViewModel())
                .environmentObject(myViewCoordinator)
                .tabItem {
                    Image("movie")
                    Text(verbatim: "MY")
                }
        }
        .tint(.app)
    }
}
