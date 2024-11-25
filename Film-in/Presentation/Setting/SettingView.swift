//
//  SettingView.swift
//  Film-in
//
//  Created by Minjae Kim on 10/4/24.
//

import SwiftUI

fileprivate enum SettingCase: CaseIterable {
    case version
    case inquiry
    case privacyPolicy
    
    var titleKey: LocalizedStringKey {
        switch self {
        case .version:
            "version"
        case .inquiry:
            "inquiry"
        case .privacyPolicy:
            "privacyPolicy"
        }
    }
}

struct SettingView: View {
    var body: some View {
        List {
            ForEach(SettingCase.allCases, id: \.self) { setting in
                switch setting {
                case .version:
                    HStack {
                        Text(setting.titleKey)
                    }
                case .inquiry:
                    Text(setting.titleKey)
                case .privacyPolicy:
                    Text(setting.titleKey)
                }
            }
        }
        .listStyle(.plain)
    }
}

#Preview {
    SettingView()
}
