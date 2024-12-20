//
//  SearchFactory.swift
//  Film-in
//
//  Created by Minjae Kim on 12/4/24.
//

import SwiftUI

enum SearchFactory {
    static func makeView() -> some View {
        SearchView(
            viewModel: SearchViewModel(
                searchSerivce: DefaultSearchService(
                    tmdbRepository: DefaultTMDBRepository.shared
                ),
                networkMonitor: NetworkMonitor.shared
            )
        )
    }
    
    static func makeView(
        isShowSearch: Binding<Bool>,
        focusedField: FocusState<FocusField?>.Binding,
        namespace: Namespace.ID
    ) -> some View {
        SearchResultView(
            viewModel: SearchResultViewModel(
                networkMonitor: NetworkMonitor.shared,
                searchResultService: DefaultSearchResultService(
                    tmdbRepository: DefaultTMDBRepository.shared
                )
            ),
            isShowSearch: isShowSearch,
            focusedField: focusedField,
            namespace: namespace
        )
    }
}
