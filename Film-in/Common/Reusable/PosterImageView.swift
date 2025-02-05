//
//  PosterImageView.swift
//  Film-in
//
//  Created by Minjae Kim on 9/29/24.
//

import SwiftUI
import ImageIO
import Kingfisher

struct PosterImage: View {
    let url: URL?
    let size: CGSize
    let title: String
    let isDownsampling: Bool
    
    var body: some View {
        KFImage(url)
            .resizable()
            .scaleFactor(UITraitCollection.current.displayScale)
            .setProcessors([DownsamplingImageProcessor(size: size)])
            .placeholder{
                Text(verbatim: title)
                    .foregroundStyle(.appText)
            }
            .cacheOriginalImage()
            .cancelOnDisappear(true)
            .fade(duration: 0.25)
            .aspectRatio(contentMode: .fill)
            .frame(width: size.width, height: size.height)
            .clipped()
    }
}
