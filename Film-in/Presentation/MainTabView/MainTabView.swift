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
                    Text(verbatim: "HOME")
                }
            
            SearchFactory
                .makeView()
                .tabItem {
                    Image("search")
                    Text(verbatim: "SEARCH")
                }
            
            MyFactory
                .makeView()
                .tabItem {
                    Image("movie")
                    Text(verbatim: "MY")
                }
        }
        .tint(.app)
    }
}
