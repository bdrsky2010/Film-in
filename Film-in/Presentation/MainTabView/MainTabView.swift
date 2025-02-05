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
                    Text(R.Phrase.home)
                }
            
            CoordinatorView(destination: .search)
                .tabItem {
                    Image("search")
                    Text(R.Phrase.search)
                }
            
            CoordinatorView(destination: .my)
                .tabItem {
                    Image("movie")
                    Text(R.Phrase.my)
                }
        }
        .tint(.app)
    }
}
