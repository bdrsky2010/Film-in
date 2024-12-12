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
            HomeFactory
                .makeView()
                .tabItem {
                    Image("home")
                    Text("HOME")
                }
            
            SearchFactory
                .makeView()
                .tabItem {
                    Image("search")
                    Text("SEARCH")
                }
            
            MyFactory
                .makeView()
                .tabItem {
                    Image("movie")
                    Text("MY")
                }
        }
        .tint(.app)
    }
}
