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
        if isDownsampling {
            KFImage(url)
                .resizable()
                .setProcessor(DownsampleProcessor(pointSize: size))
                .placeholder{
                    Text(title)
                        .foregroundStyle(.appText)
                }
                .cacheOriginalImage()
                .cancelOnDisappear(true)
                .fade(duration: 0.25)
                .aspectRatio(contentMode: .fill)
                .frame(width: size.width, height: size.height)
                .clipped()
        } else {
            KFImage(url)
                .resizable()
                .placeholder{
                    Text(title)
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
}

struct DownsampleProcessor: ImageProcessor {
    let identifier: String
    let pointSize: CGSize
    
    init(pointSize: CGSize) {
        self.identifier = "com.example.DownsampleProcessor.\(pointSize)"
        self.pointSize = pointSize
    }

    func process(item: ImageProcessItem, options: KingfisherParsedOptionsInfo) -> KFCrossPlatformImage? {
        switch item {
        case .image(let image):
            guard let data = image.pngData() else { return nil }
            return downsampling(data: data, pointSize: pointSize, scale: UITraitCollection.current.displayScale)
        case .data(let data):
            return downsampling(data: data, pointSize: pointSize, scale: UITraitCollection.current.displayScale)
        }
    }

    private func downsampling(data: Data, pointSize: CGSize, scale: CGFloat) -> KFCrossPlatformImage? {
        let imageSourceOption = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let imageSource = CGImageSourceCreateWithData(data as CFData, imageSourceOption) else {
            print("\(#function) -> imageSource exit")
            return nil
        }
        
        let maxDimensionsInPixels = max(pointSize.width, pointSize.height) * scale
        let downsampleOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimensionsInPixels
        ] as CFDictionary
        
        guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) else {
            print("\(#function) -> downsampledImage exit")
            return nil
        }
        
        return UIImage(cgImage: downsampledImage)
    }
}
