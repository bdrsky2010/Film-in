//
//  Publisher+.swift
//  Film-in
//
//  Created by Minjae Kim on 12/7/24.
//

import Combine

extension Publisher {
    func sink<Object: AnyObject>(with object: Object, receiveCompletion: @escaping ((Object, Subscribers.Completion<Self.Failure>) -> Void), receiveValue: @escaping ((Object, Self.Output) -> Void)) -> AnyCancellable {
        self.sink { [weak object] completion in
            guard let object else { return }
            receiveCompletion(object, completion)
        } receiveValue: { [weak object] output in
            guard let object else { return }
            receiveValue(object, output)
        }
    }
}

extension Publisher where Self.Failure == Never {
    func sink<Object: AnyObject>(with object: Object, receiveValue: @escaping ((Object, Self.Output) -> Void)) -> AnyCancellable {
        self
            .sink { [weak object] output in
                guard let object else { return }
                receiveValue(object, output)
            }
    }
}
