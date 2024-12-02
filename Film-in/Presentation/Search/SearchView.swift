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
    
    @FocusState private var isCoverFocused: Bool
    @FocusState private var isSearchFocused: Bool
    
    @State private var selection: SearchTab = .movie
    @State private var isShowSearch = false
    @State private var searchQuery = ""
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    HStack {
                        TextField("searchPlaceholder", text: $searchQuery)
                            .focused($isCoverFocused)
                            .padding()
                            .font(.ibmPlexMonoSemiBold(size: 16))
                        
                        if !searchQuery.isEmpty {
                            Button {
                                searchQuery = ""
                            } label: {
                                Image(systemName: "xmark.app.fill")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundStyle(.app)
                                    .padding(.trailing)
                            }
                        }
                    }
                    .overlay {
                        Rectangle()
                            .stroke(lineWidth: 3)
                            .matchedGeometryEffect(id: "TextField", in: namsespace)
                            .animation(.easeInOut, value: isShowSearch)
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
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    
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
            if isShowSearch {
                VStack {
                    HStack {
                        HStack {
                            TextField("searchPlaceholder", text: $searchQuery)
                                .focused($isSearchFocused)
                                .padding()
                                .font(.ibmPlexMonoSemiBold(size: 16))
                            
                            if !searchQuery.isEmpty {
                                Button {
                                    searchQuery = ""
                                } label: {
                                    Image(systemName: "xmark.app.fill")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                        .foregroundStyle(.app)
                                        .padding(.trailing)
                                }
                            }
                        }
                        .overlay {
                            Rectangle()
                                .stroke(lineWidth: 3)
                                .matchedGeometryEffect(id: "TextField", in: namsespace)
                                .animation(.easeInOut, value: isShowSearch)
                        }
                        
                        Button {
                            isShowSearch.toggle()
                        } label: {
                            Text("cancel")
                                .tint(.app)
                                .font(.ibmPlexMonoSemiBold(size: 20))
                                .padding(.leading, 8)
                        }
                        .matchedGeometryEffect(id: "Cancel", in: namsespace)
                    }
                    .padding(.horizontal)
                    Spacer()
                }
                .background(.background)
            }
        }
        .valueChanged(value: isCoverFocused) { _ in
            if isCoverFocused {
                withAnimation {
                    isShowSearch.toggle()
                    isSearchFocused = true
                }
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
