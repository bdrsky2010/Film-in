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
    
    var input: Input { get }
    var output: Output { get }
    var cancellable: Set<AnyCancellable> { get }
    
    func transform()
    func action(_ action: Action)
}
