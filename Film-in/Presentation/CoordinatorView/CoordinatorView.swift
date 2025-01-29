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
    @State private var isRootAppear: Bool = true
    
    let destination: Destination
    
    var body: some View {
        NavigationStack(
            path: Binding { coordinator.navigationPath }
            set: { _ in coordinator.pop() }
        ) {
            rootView(destination)
                .onAppear(perform: rootAppear)
                .setToolbarVisibility(visibility, for: .tabBar)
                .animation(.easeInOut, value: visibility)
                .navigationDestination(for: AppRoute.self) { route in
                    coordinator.bulid(route)
                        .onAppear(perform: childAppear)
                        .onDisappear(perform: childDisappear)
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

extension CoordinatorView {
    private func rootAppear() {
        isRootAppear = true
    }
    
    private func childAppear() {
        if visibility == .visible {
            visibility = .hidden
        }
        isRootAppear = false
    }
    
    private func childDisappear() {
        if isRootAppear { visibility = .visible }
    }
}
