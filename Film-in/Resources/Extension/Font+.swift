//
//  Font+.swift
//  Film-in
//
//  Created by Minjae Kim on 9/25/24.
//

import SwiftUI

extension Font {
    static func ibmPlexMonoRegular(size: CGFloat) -> Font {
        return .custom(R.CustomFont.ibmPlexMonoRegular, size: size)
    }
    
    static func ibmPlexMonoMedium(size: CGFloat) -> Font {
        return .custom(R.CustomFont.ibmPlexMonoMedium, size: size)
    }
    
    static func ibmPlexMonoSemiBold(size: CGFloat) -> Font {
        return .custom(R.CustomFont.ibmPlexMonoSemiBold, size: size)
    }
}
