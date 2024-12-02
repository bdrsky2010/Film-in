//
//  SearchView.swift
//  Film-in
//
//  Created by Minjae Kim on 12/1/24.
//

import SwiftUI
import Combine

enum SearchTab: CaseIterable, CustomStringConvertible {
    case movie, person
    
    var description: String {
        switch self {
        case .movie:  "MOVIE"
        case .person: "ACTOR"
        }
    }
    
    @ViewBuilder
    var view: some View {
        switch self {
        case .movie: FirstView()
        case .person: SecondView()
        }
    }
}

struct SearchView: View {
    @Namespace private var namsespace
    
    @FocusState private var isFocused: Bool
    
    @State private var selection: SearchTab = .movie
    @State private var searchQuery = ""
    
    var body: some View {
        HStack {
            TextField("", text: $searchQuery)
                .focused($isFocused)
                .padding()
                .border(.appText, width: 3)
            
            Button {
                isFocused.toggle()
            } label: {
                Text(verbatim: "취소")
                    .tint(.app)
                    .font(.ibmPlexMonoSemiBold(size: 20))
            }
        }
        .padding(.horizontal)
        
        VStack {
            HStack(spacing: 12) {
                ForEach(SearchTab.allCases, id: \.self) { tab in
                    ZStack {
                        Text(verbatim: tab.description)
                            .font(.ibmPlexMonoSemiBold(size: 20))
                            .bold()
                            .padding(.bottom, 12)
                    }
                            .overlay(alignment: .bottom) {
                                if selection == tab {
                                    Capsule()
                                        .frame(height: 4)
                                        .foregroundStyle(.app)
                                        .matchedGeometryEffect(id: "tab", in: namsespace)
                                }
                            }
                            .animation(.easeInOut, value: selection)
                            .onTapGesture {
                                selection = tab
                            }
                        }
                    }
                    
                    TabView(selection: $selection) {
                        ForEach(SearchTab.allCases, id: \.self) { tab in
                            LazyView(tab.view)
                                .tabItem { }
                                .tag(tab)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .animation(.easeInOut, value: selection)
                    .ignoresSafeArea()
                }
            }
            }
        }
        .overlay {
            if isFocused {
                Rectangle()
            }
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
