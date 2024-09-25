//
//  Font+.swift
//  Film-in
//
//  Created by Minjae Kim on 9/25/24.
//

import SwiftUI

extension Font {
    static func notoSansMedium(size: CGFloat) -> Font {
        return .custom("NotoSansKR-Medium", size: size)
    }
    
    static func notoSansSemiBold(size: CGFloat) -> Font {
        return .custom("NotoSansKR-SemiBold", size: size)
    }
    
    static func notoSansBold(size: CGFloat) -> Font {
        return .custom("NotoSansKR-Bold", size: size)
    }
}
