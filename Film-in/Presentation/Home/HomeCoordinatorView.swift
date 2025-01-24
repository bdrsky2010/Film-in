//
//  HomeCoordinatorView.swift
//  Film-in
//
//  Created by Minjae Kim on 1/24/25.
//

import SwiftUI

struct HomeCoordinatorView: View {
    @StateObject private var coordinator = Coordinator()
    
    var body: some View {
        NavigationStack(
            path: Binding { coordinator.navigationPath }
            set: { _ in coordinator.pop() }
        ) {
            coordinator.bulid(.home)
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
}
