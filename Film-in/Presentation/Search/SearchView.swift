//
//  SearchView.swift
//  Film-in
//
//  Created by Minjae Kim on 12/1/24.
//

import SwiftUI

enum SearchTab: CaseIterable, CustomStringConvertible {
    case movie, person
    
    var description: String {
        switch self {
        case .movie:  "MOVIE"
        case .person: "ACTOR"
        }
    }
}

struct SearchView: View {
    @Namespace var namsespace
    @State private var selection: SearchTab = .movie
    @State private var searchQuery = ""
    
    var body: some View {
        VStack {
            TextField("", text: $searchQuery)
                .padding()
                .border(.red)
            
            HStack {
                ForEach(SearchTab.allCases, id: \.hashValue) { tab in
                    Spacer()
                    ZStack {
                        Text(verbatim: tab.description)
                            .font(.title2)
                            .bold()
                            .padding(.bottom, 12)
                    }
                    .frame(maxWidth: .infinity)
                    .overlay(alignment: .bottom) {
                        if selection == tab {
                            Capsule()
                                .frame(height: 4)
                                .matchedGeometryEffect(id: "tab", in: namsespace)
                        }
                    }
                    .animation(.easeInOut, value: selection)
                    .onTapGesture {
                        selection = tab
                    }
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
            
            TabView(selection: $selection) {
                LazyView(FirstView())
                    .tabItem { }
                    .tag(SearchTab.movie)
                LazyView(SecondView())
                    .tabItem { }
                    .tag(SearchTab.person)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
    }
}
 
struct FirstView: View {
    init() {
        print(String(describing: self))
    }
    
    var body: some View {
        Text("Tab Content 1")
            .task {
                print(String(describing: self) + "task")
            }
    }
}

struct SecondView: View {
    init() {
        print(String(describing: self))
    }
    
    var body: some View {
        Text("Tab Content 2")
            .task {
                print(String(describing: self) + "task")
            }
    }
}

#Preview {
    SearchView()
}
