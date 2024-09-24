//
//  BaseViewModel.swift
//  Film-in
//
//  Created by Minjae Kim on 9/24/24.
//

import Foundation
import Combine

protocol BaseViewModel: ObservableObject {
    associatedtype Input
    associatedtype Output
    
    var input: Input { get set }
    var output: Output { get set }
    var cancellable: Set<AnyCancellable> { get set }
    
    func transform()
}
