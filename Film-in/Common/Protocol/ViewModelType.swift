//
//  ViewModelType.swift
//  Film-in
//
//  Created by Minjae Kim on 9/25/24.
//

import Foundation
import Combine

protocol ViewModelType: ObservableObject where Self: BaseObject {
    associatedtype Input
    associatedtype Output
    associatedtype Action
    
    var input: Input { get set }
    var output: Output { get set }
    var cancellable: Set<AnyCancellable> { get set }
    
    func transform()
    func action(_ action: Action)
}
