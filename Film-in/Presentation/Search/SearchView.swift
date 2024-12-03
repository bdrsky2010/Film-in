//
//  SearchView.swift
//  Film-in
//
//  Created by Minjae Kim on 12/2/24.
//

import SwiftUI

struct SearchView: View {
    @State private var cellSize: CGSize = .zero
    @State private var posterSize: CGSize = .zero
    
    @Namespace private var namespace
    
    @FocusState private var isCoverFocused: Bool
    @FocusState private var isSearchFocused: Bool
    
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
                            .matchedGeometryEffect(id: "TextField", in: namespace)
                    }
                }
                .padding(.horizontal)
                
                GeometryReader { proxy in
                    List {
                        ForEach(SearchTab.allCases, id: \.self) { tab in
                            Section {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack {
                                        switch tab {
                                        case .movie:
                                            ForEach(0..<10) { _ in
                                                Rectangle()
                                                    .frame(width: cellSize.width, height: cellSize.height)
                                                    .foregroundStyle(Color.init(red: Double.random(in: 0...1), green: Double.random(in: 0...1), blue: Double.random(in: 0...1)))
                                            }
                                        case .person:
                                            ForEach(0..<10) { _ in
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
                            } header: {
                                Text(verbatim: tab.description)
                                    .font(.ibmPlexMonoSemiBold(size: 20))
                                    .bold()
                                    .foregroundStyle(.appText)
                                    .padding(.bottom, 4)
                                    .matchedGeometryEffect(id: "\(tab.description)", in: namespace)
                            }
                        }
                    }
                    .listStyle(.plain)
                    .task {
                        if cellSize == .zero {
                            cellSize = CGSize(
                                width: (proxy.size.width - (8 * 2)) / 3 * 0.8,
                                height: (proxy.size.width - (8 * 2)) / 3 * 1.5 * 0.8
                            )
                        }
                        
                        if posterSize == .zero {
                            posterSize = CGSize(width: proxy.size.width * 0.7, height: proxy.size.width * 0.7 * 1.5)
                        }
                    }
                }
            }
            if isShowSearch {
                SearchResultView(
                    searchQuery: $searchQuery,
                    isShowSearch: $isShowSearch,
                    isCoverFocused: $isCoverFocused,
                    isSearchFocused: $isSearchFocused,
                    namespace: namespace
                )
            }
        }
        .background(.background)
        .ignoresSafeArea(edges: .bottom)
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

#Preview {
    SearchView()
}
