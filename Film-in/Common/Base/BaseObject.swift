//
//  BaseViewModel.swift
//  Film-in
//
//  Created by Minjae Kim on 9/24/24.
//

import Foundation
import Combine

class BaseObject: ObservableObject {
    init() {
        print("\(String(describing: self)) is init")
    }
    
    deinit {
        print("\(String(describing: self)) is deinit")
    }
}
