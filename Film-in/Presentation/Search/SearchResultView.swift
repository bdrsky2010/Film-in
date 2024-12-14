//
//  SearchView.swift
//  Film-in
//
//  Created by Minjae Kim on 12/1/24.
//

import SwiftUI
import Combine

fileprivate extension SearchType {
    @ViewBuilder
    func makeView(query: String, isShowAlert: Binding<Bool>, isRefresh: Binding<Bool>) -> some View {
        switch self {
        case .movie:
            MultiListFactory.makeView(to: .searchMovie(query), isShowAlert: isShowAlert, isRefresh: isRefresh)
        case .person:
            MultiListFactory.makeView(to: .searchPerson(query), isShowAlert: isShowAlert, isRefresh: isRefresh)
        }
    }
}

struct SearchResultView: View {
    @StateObject private var viewModel: SearchResultViewModel
    
    @AppStorage("recentQuery") private var recentQuery: [String : Date] = [:]
    
    @State private var selection: SearchType = .movie
    @State private var searchQuery = ""
    @State private var isFirstSearch = true
    @State private var isShowAlert = false
    @State private var isRefresh = false
    
    @Binding private var isShowSearch: Bool
    
    private var focusedField: FocusState<FocusField?>.Binding
    
    private let namespace: Namespace.ID
    
    init(
        viewModel: SearchResultViewModel,
        isShowSearch: Binding<Bool>,
        focusedField: FocusState<FocusField?>.Binding,
        namespace: Namespace.ID
    ) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self._isShowSearch = isShowSearch
        self.focusedField = focusedField
        self.namespace = namespace
    }
    
    var body: some View {
        VStack {
            HStack {
                if viewModel.output.isSearched {
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
                            if isFirstSearch { isFirstSearch = false }
                            if searchQuery.isEmpty {
                                viewModel.action(.getRandomSearchQuery)
                                searchQuery = viewModel.output.randomSearchQuery
                            }
                            recentQuery[searchQuery] = Date()
                            viewModel.action(.onSubmitSearchQuery(searchQuery))
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
                
                if !viewModel.output.isSearched {
                    Button {
                        withAnimation {
                            if isFirstSearch {
                                searchQuery = ""
                                isShowSearch = false
                            } else {
                                focusedField.wrappedValue = nil
                                viewModel.action(.onDismiss)
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
            .animation(.easeInOut, value: viewModel.output.isSearched)

            if viewModel.output.isSearched {
                VStack {
                    HStack(spacing: 12) {
                        ForEach(SearchType.allCases, id: \.self) { tab in
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
                        ForEach(SearchType.allCases, id: \.self) { tab in
                            LazyView(tab.makeView(
                                query: searchQuery,
                                isShowAlert: $isShowAlert,
                                isRefresh: $isRefresh
                            ))
                                .tabItem { }
                                .tag(tab)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .animation(.easeInOut, value: selection)
                    .ignoresSafeArea(edges: .bottom)
                }
            } else {
                List {
                    if searchQuery.isEmpty {
                        Section {
                            ForEach(recentQuery.sorted(by: { $0.value > $1.value }), id: \.key) { query in
                                Text(verbatim: query.key)
                                    .onTapGesture {
                                        if isFirstSearch { isFirstSearch = false }
                                        searchQuery = query.key
                                        focusedField.wrappedValue = nil
                                        recentQuery[searchQuery] = Date()
                                        viewModel.action(.onSubmitSearchQuery(searchQuery))
                                    }
                            }
                            .onDelete(perform: deleteRecentQuery)
                        } header: {
                            HStack(alignment: .lastTextBaseline) {
                                Text(verbatim: "최근 검색어")
                                    .font(.ibmPlexMonoSemiBold(size: 20))
                                    .bold()
                                    .foregroundStyle(.appText)
                                    .padding(.bottom, 4)
                                
                                Spacer()
                                
                                Button {
                                    recentQuery.removeAll()
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
                            ForEach(viewModel.output.multiSearchList, id: \.self) { item in
                                HStack{
                                    Image(systemName: item.type == .movie ? "movieclapper.fill" : "person.fill")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                    Text(verbatim: item.keyword)
                                        .onTapGesture {
                                            if isFirstSearch { isFirstSearch = false }
                                            searchQuery = item.keyword
                                            focusedField.wrappedValue = nil
                                            recentQuery[searchQuery] = Date()
                                            viewModel.action(.onSubmitSearchQuery(searchQuery))
                                        }
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
                .animation(.easeInOut, value: recentQuery)
            }
        }
        .background(.background)
        .valueChanged(value: focusedField.wrappedValue) { _ in
            if focusedField.wrappedValue == .search {
                viewModel.action(.onFocusTextField)
            }
        }
        .valueChanged(value: searchQuery) { query in
            viewModel.action(.onChangeSearchQuery(query))
        }
        .popupAlert(
            isPresented: Binding(
                get: { viewModel.output.isShowAlert },
                set: { _ in viewModel.action(.onDismissAlert) }
            ),
            contentModel: .init(
                systemImage: "wifi.exclamationmark",
                phrase: "apiRequestError",
                normal: "refresh"
            ),
            heightType: .middle
        ) {
            viewModel.action(.onChangeSearchQuery(searchQuery))
        }
        .popupAlert(
            isPresented: $isShowAlert,
            contentModel: .init(
                systemImage: "wifi.exclamationmark",
                phrase: "apiRequestError",
                normal: "refresh"
            ),
            heightType: .middle
        ) {
            isRefresh = true
        }
    }
}

extension SearchResultView {
    private func addRecentQuery() {
        recentQuery[searchQuery] = Date()
        if recentQuery.count > 10 {
            while recentQuery.count > 10 {
                if let key = recentQuery.sorted(by: { $0.value < $1.value }).first?.key {
                    recentQuery.removeValue(forKey: key)
                }
            }
        }
    }
    
    private func deleteRecentQuery(at offsets: IndexSet) {
        guard let index = offsets.first else { return }
        let key = recentQuery.sorted(by: { $0.value > $1.value })[index].key
        recentQuery.removeValue(forKey: key)
    }
}
