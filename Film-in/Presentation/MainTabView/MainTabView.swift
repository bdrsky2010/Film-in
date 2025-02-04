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
                    Text("home")
                }
            
            CoordinatorView(destination: .search)
                .tabItem {
                    Image("search")
                    Text("search")
                }
            
            CoordinatorView(destination: .my)
                .tabItem {
                    Image("movie")
                    Text("my")
                }
        }
        .tint(.app)
    }
}
