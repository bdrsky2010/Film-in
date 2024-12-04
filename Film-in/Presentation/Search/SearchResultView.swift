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
    @State private var selection: SearchTab = .movie
    @State private var isFirstSearch = true
    @State private var isSearching = false
    @State private var isSearched = false
    @State private var previousQuery = ""
    
    @Binding private var searchQuery: String
    @Binding private var isShowSearch: Bool
    
    private var focusedField: FocusState<FocusField?>.Binding
    
    private let namespace: Namespace.ID
    
    init(
        searchQuery: Binding<String>,
        isShowSearch: Binding<Bool>,
        focusedField: FocusState<FocusField?>.Binding,
        namespace: Namespace.ID
    ) {
        self._searchQuery = searchQuery
        self._isShowSearch = isShowSearch
        self.focusedField = focusedField
        self.namespace = namespace
    }
    
    var body: some View {
        VStack {
            HStack {
                if isSearched {
                    Button {
                        withAnimation {
                            searchQuery = ""
                            isShowSearch = false
                        }
                    } label: {
                        Image(systemName: "chevron.backward")
                            .tint(.app)
                            .font(.title.bold())
                            .padding(.trailing, 8)
                    }
                }
                
                HStack {
                    TextField("searchPlaceholder", text: $searchQuery)
                        .focused(focusedField, equals: .search)
                        .autocorrectionDisabled()
                        .submitLabel(.search)
                        .padding()
                        .font(.ibmPlexMonoSemiBold(size: 16))
                        .onSubmit {
                            focusedField.wrappedValue = nil
                            if isFirstSearch { isFirstSearch = false }
                            
                            withAnimation {
                                isSearching = true
                                isSearched = true
                            }
                        }
                    
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
                
                if !isSearched {
                    Button {
                        withAnimation {
                            if isFirstSearch {
                                searchQuery = ""
                                isShowSearch = false
                            } else {
                                isSearched = true
                                focusedField.wrappedValue = nil
                            }
                        }
                    } label: {
                        Text("cancel")
                            .tint(.app)
                            .font(.ibmPlexMonoSemiBold(size: 20))
                            .padding(.leading, 8)
                    }
                }
            }
            .padding(.horizontal)

            if isSearched {
                if isSearching {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    VStack {
                        HStack(spacing: 12) {
                            ForEach(SearchTab.allCases, id: \.self) { tab in
                                Text(verbatim: tab.description)
                                    .font(.ibmPlexMonoSemiBold(size: 20))
                                    .bold()
                                    .foregroundStyle(.appText)
                                    .padding(.bottom, 4)
                                    .matchedGeometryEffect(id: "\(tab.description)", in: namespace)
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
                        .ignoresSafeArea(edges: .bottom)
                    }
                }
            } else {
                List {
                    if searchQuery.isEmpty {
                        Section {
                            ForEach(0..<20) { i in
                                HStack {
                                    NavigationLink("\(i) 번째 이야기", destination: EmptyView())
                                }
                            }
                        } header: {
                            HStack(alignment: .lastTextBaseline) {
                                Text(verbatim: "최근 검색어")
                                    .font(.ibmPlexMonoSemiBold(size: 20))
                                    .bold()
                                    .foregroundStyle(.appText)
                                    .padding(.bottom, 4)
                                
                                Button {
                                    // TODO: UserDefaults or AppStorage Data 삭제
                                } label: {
                                    Text(verbatim: "전체삭제")
                                        .font(.ibmPlexMonoSemiBold(size: 14))
                                        .bold()
                                        .foregroundStyle(.app)
                                        .underline()
                                        .padding(.bottom, 4)
                                }
                            }
                        }
                    } else {
                        Section {
                            ForEach(0..<20) { i in
                                HStack {
                                    NavigationLink("\(i) 번째 이야기", destination: EmptyView())
                                }
                            }
                        } header: {
                            Text(verbatim: "연관 검색어")
                                .font(.ibmPlexMonoSemiBold(size: 20))
                                .bold()
                                .foregroundStyle(.appText)
                                .padding(.bottom, 4)
                        }
                    }
                }
                .listStyle(.plain)
                .scrollDismissesKeyboard(.interactively)
            }
        }
        .background(.background)
        .valueChanged(value: focusedField.wrappedValue) { _ in
            if focusedField.wrappedValue == .search {
                withAnimation {
                    isSearched = false
                }
            }
        }
        .valueChanged(value: searchQuery) { _ in
            // TODO: RequestAPI(Debounce) -> Search/Multi
        }
        .valueChanged(value: isSearching) { _ in
            if isSearching, previousQuery != searchQuery {
                // TODO: RequestAPI(Throttle) -> Search/Movie & Actor
                Task {
                    try await Task.sleep(nanoseconds: 1_500_000_000)
                    isSearching = false
                    previousQuery = searchQuery
                }
            } else {
                isSearching = false
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
