//
//  CoordinatorView.swift
//  Film-in
//
//  Created by Minjae Kim on 1/25/25.
//

import SwiftUI

struct CoordinatorView: View {
    enum Destination {
        case home, search, My
    }
    
    @StateObject private var coordinator = Coordinator()
    
    @State private var visibility: Visibility = .visible
    
    let destination: Destination
    
    var body: some View {
        NavigationStack(
            path: Binding { coordinator.navigationPath }
            set: { _ in coordinator.pop() }
        ) {
            rootView(destination)
                .onAppear { visibility = .visible }
                .onDisappear { visibility = .hidden }
                .setToolbarVisibility(visibility, for: .tabBar)
                .animation(.easeInOut, value: visibility)
                .navigationDestination(for: AppRoute.self) { route in
                    coordinator.bulid(route)
                }
                .sheet(item: Binding(get: { coordinator.sheet }, set: { _ in })) { sheet in
                    coordinator.buildSheet(sheet)
                }
        }
        .environmentObject(coordinator)
    }
    
    @ViewBuilder
    func rootView(_ destination: Destination) -> some View {
        switch destination {
        case .home:
            coordinator.bulid(.home)
        case .search:
            coordinator.bulid(.search)
        case .My:
            coordinator.bulid(.myView)
        }
    }
}
