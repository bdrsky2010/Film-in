//
//  View+.swift
//  Film-in
//
//  Created by Minjae Kim on 9/24/24.
//

import SwiftUI

extension View {
    @ViewBuilder func valueChanged<T: Equatable>(value: T, onChange: @escaping (T) -> Void) -> some View {
        if #available(iOS 17.0, *) {
            self.onChange(of: value) {
                onChange(value)
            }
        } else {
            self.onChange(of: value) { value in
                onChange(value)
            }
        }
    }
}
