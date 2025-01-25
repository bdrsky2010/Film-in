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
    
    let destination: Destination
    
    var body: some View {
        NavigationStack(
            path: Binding { coordinator.navigationPath }
            set: { _ in coordinator.pop() }
        ) {
            routeSection(destination)
                .navigationDestination(for: AppRoute.self) { route in
                    coordinator.bulid(route)
                }
                .sheet(
                    item: Binding(get: { coordinator.sheet },
                                  set: { _ in coordinator.dismissSheet() })
                ) { sheet in
                    coordinator.buildSheet(sheet)
                }
        }
        .environmentObject(coordinator)
    }
    
    @ViewBuilder
    func routeSection(_ destination: Destination) -> some View {
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
