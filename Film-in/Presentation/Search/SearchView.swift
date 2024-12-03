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
    
    @Binding private var searchQuery: String
    @Binding private var isShowSearch: Bool
    
    private var isCoverFocused: FocusState<Bool>.Binding
    private var isSearchFocused: FocusState<Bool>.Binding
    
    private let namespace: Namespace.ID
    
    init(
        searchQuery: Binding<String>,
        isShowSearch: Binding<Bool>,
        isCoverFocused: FocusState<Bool>.Binding,
        isSearchFocused: FocusState<Bool>.Binding,
        namespace: Namespace.ID
    ) {
        self._searchQuery = searchQuery
        self._isShowSearch = isShowSearch
        self.isCoverFocused = isCoverFocused
        self.isSearchFocused = isSearchFocused
        self.namespace = namespace
    }
    
    var body: some View {
        VStack {
            HStack {
                HStack {
                    TextField("searchPlaceholder", text: $searchQuery)
                        .focused(isSearchFocused)
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
                
                Button {
                    withAnimation {
                        isShowSearch.toggle()
                    }
                } label: {
                    Text("cancel")
                        .tint(.app)
                        .font(.ibmPlexMonoSemiBold(size: 20))
                        .padding(.leading, 8)
                }
                .matchedGeometryEffect(id: "Cancel", in: namespace)
            }
            .padding(.horizontal)
            
//            Spacer()
            
            GeometryReader { proxy in
                List {
                    if searchQuery.isEmpty {
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
                }
                .listStyle(.plain)
                .scrollDismissesKeyboard(.interactively)
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
        }
        .background(.background)
    }
}
