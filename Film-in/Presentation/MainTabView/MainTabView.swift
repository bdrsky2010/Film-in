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
            CoordinatorView(destination: .home)
                .tabItem {
                    Image("home")
                    Text(verbatim: "HOME")
                }
            
            CoordinatorView(destination: .search)
                .tabItem {
                    Image("search")
                    Text(verbatim: "SEARCH")
                }
            
            CoordinatorView(destination: .My)
                .tabItem {
                    Image("movie")
                    Text(verbatim: "MY")
                }
        }
        .tint(.app)
    }
}
