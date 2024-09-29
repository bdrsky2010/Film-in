//
//  PosterImageView.swift
//  Film-in
//
//  Created by Minjae Kim on 9/29/24.
//

import SwiftUI
import Kingfisher

struct PosterImage: View {
    let url: URL?
    let size: CGSize
    let title: String
    
    var body: some View {
        KFImage(url)
            .resizable()
            .placeholder{
                Text(title)
                    .foregroundStyle(.appText)
            }
            .loadDiskFileSynchronously()
            .cacheMemoryOnly()
            .fade(duration: 0.25)
            .aspectRatio(contentMode: .fill)
            .frame(width: size.width, height: size.height)
            .clipped()
    }
}
