//
//  Print.swift
//  Film-in
//
//  Created by Minjae Kim on 12/15/24.
//

public func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    #if DEBUG
    Swift.print(items, separator: separator, terminator: terminator)
    #endif
}
