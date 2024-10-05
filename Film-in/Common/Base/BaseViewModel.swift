//
//  BaseViewModel.swift
//  Film-in
//
//  Created by Minjae Kim on 9/24/24.
//

import Foundation
import Combine

class BaseViewModel: ObservableObject {
    init() {
        print("\(String(describing: self)) is init")
    }
    
    deinit {
        print("\(String(describing: self)) is deinit")
    }
}
