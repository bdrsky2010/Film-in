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

struct SearchResultView: View {
    @Namespace private var namespace
    
    @FocusState private var isCoverFocused: Bool
    @FocusState private var isSearchFocused: Bool
    
    @State private var selection: SearchTab = .movie
    @State private var isShowSearch = false
    @State private var searchQuery = ""
    
    var body: some View {
        let _ = Self._printChanges()
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
                            .matchedGeometryEffect(id: "TextField", in: namespace)
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
                                    .foregroundStyle(.appText)
                                    .padding(.bottom, 12)
                                    .matchedGeometryEffect(id: "\(tab.description)", in: namespace, isSource: !isShowSearch)
                            }
                            .overlay(alignment: .bottom) {
                                if selection == tab {
                                    Capsule()
                                        .frame(height: 4)
                                        .foregroundStyle(.app)
                                        .matchedGeometryEffect(id: "tab", in: namespace)
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
                SearchView(
                    searchQuery: $searchQuery,
                    isShowSearch: $isShowSearch,
                    isCoverFocused: $isCoverFocused,
                    isSearchFocused: $isSearchFocused,
                    namespace: namespace
                )
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
    @State private var cellSize: CGSize = .zero
    @State private var posterSize: CGSize = .zero
    
    private let gridItemLayout = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    init() {
        print("FirstView")
    }
    
    var body: some View {
        GeometryReader { proxy in
            let width = (proxy.size.width - (8 * 2)) / 3
            let height = (proxy.size.width - (8 * 2)) / 3 * 1.5
            ScrollView {
                LazyVGrid(columns: gridItemLayout) {
                    ForEach(0..<100) { _ in
                        Rectangle()
                            .frame(width: width, height: height)
                            .foregroundStyle(Color.init(red: Double.random(in: 0...1), green: Double.random(in: 0...1), blue: Double.random(in: 0...1)))
                    }
                }
            }
            .task {
                if cellSize == .zero {
                    cellSize = CGSize(
                        width: (proxy.size.width - (8 * 2)) / 3,
                        height: (proxy.size.width - (8 * 2)) / 3 * 1.5
                    )
                }
                
                if posterSize == .zero {
                    posterSize = CGSize(width: proxy.size.width * 0.7, height: proxy.size.width * 0.7 * 1.5)
                }
            }
        }
        .background(.background)
    }
}

struct SecondView: View {
    @State private var posterSize: CGSize = .zero
    
    private let gridItemLayout = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    init() {
        print(String("SecondView"))
    }
    
    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                LazyVGrid(columns: gridItemLayout) {
                    ForEach(0..<100) { _ in
                        VStack {
                            Capsule()
                                .frame(width: 90, height: 90)
                            Text(verbatim: "이름\n이름")
                                .font(.ibmPlexMonoRegular(size: 14))
                                .foregroundStyle(.appText)
                                .frame(width: 90)
                        }
                    }
                }
            }
        }
        .background(.background)
    }
}

#Preview {
    SearchResultView()
}
