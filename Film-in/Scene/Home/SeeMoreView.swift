//
//  SeeMoreView.swift
//  Film-in
//
//  Created by Minjae Kim on 9/30/24.
//

import SwiftUI
import PopupView

struct SeeMoreView: View {
    private let usedTo: UsedTo
    
    @State private var isShowAlert = false
    @State private var isRefresh = false
    
    init(usedTo: UsedTo) {
        self.usedTo = usedTo
    }
    
    var body: some View {
        MovieListView(
            viewModel: MovieListViewModel(
                movieListService: DefaultMovieListService(
                    tmdbRepository: DefaultTMDBRepository.shared,
                    databaseRepository: RealmRepository.shared
                ),
                networkMonitor: NetworkMonitor.shared,
                usedTo: usedTo),
            isShowAlert: $isShowAlert,
            isRefresh: $isRefresh
        )
        .popup(isPresented: $isShowAlert) {
            VStack {
                Text("apiRequestError")
                    .font(.ibmPlexMonoSemiBold(size: 20))
                Button {
                    isRefresh = true
                } label: {
                    Text("refresh")
                        .font(.ibmPlexMonoMedium(size: 20))
                        .underline()
                        .foregroundStyle(.white)
                }
                .padding(.bottom, 4)
            }
            .frame(maxWidth: .infinity)
            .background(.red)
        } customize: {
            $0
                .type(.floater(verticalPadding: 0, horizontalPadding: 0, useSafeAreaInset: true))
                .animation(.bouncy)
                .position(.top)
                .dragToDismiss(true)
        }
        .toolbar(.hidden, for: .tabBar)
    }
}

#Preview {
    SeeMoreView(usedTo: .nowPlaying)
}
