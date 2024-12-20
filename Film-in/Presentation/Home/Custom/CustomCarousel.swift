//
//  CustomCarousel.swift
//  Film-in
//
//  Created by Minjae Kim on 9/26/24.
//

import SwiftUI

struct SnapCarousel<Content: View, Item: Identifiable>: View {
    private let content: (Item) -> Content
    private let list: [Item]
    private let spacing: CGFloat
    private let trailingSpace: CGFloat
    
    @Binding private var index: Int
    
    // offset
    @GestureState private var offset: CGFloat = 0
    @State private var currentIndex = 0
    
    init(spacing: CGFloat = 15, trailingSpace: CGFloat = 100, index: Binding<Int>, items: [Item], @ViewBuilder content: @escaping (Item) -> Content) {
        self.list = items
        self.spacing = spacing
        self.trailingSpace = trailingSpace
        self._index = index
        self.content = content
    }
    
    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width - (trailingSpace - spacing)
            let adjustMentWidth = (trailingSpace / 2) - spacing
            
            HStack(spacing: spacing) {
                ForEach(list, id: \.id) { item in
                    content(item)
                        .frame(width: proxy.size.width - trailingSpace)
                }
            }
            .padding(.horizontal, spacing)
            .offset(x: (CGFloat(currentIndex) * -width) + (currentIndex != 0 ? adjustMentWidth : 0) + offset)
            .gesture(
                DragGesture()
                    .updating($offset, body: { value, state, _ in
                        state = (value.translation.width / 1.5)
                    })
                    .onEnded({ value in
                        let offsetX = value.translation.width
                        let progress = -offsetX / width
                        let roundIndex = progress.rounded()
                        currentIndex = max(min(currentIndex + Int(roundIndex), list.count - 1), 0)
                        currentIndex = index
                    })
                    .onChanged({ value in
                        let offsetX = value.translation.width
                        let progress = -offsetX / width
                        let roundIndex = progress.rounded()
                        index = max(min(currentIndex + Int(roundIndex), list.count - 1), 0)
                    })
            )
        }
        .animation(.easeInOut, value: offset == 0)
    }
}

//        SnapCarousel(spacing: 28, trailingSpace: 120, index: $index, items: viewModel.output.trendingMovies.movies) { movie in
//            let url = URL(string: ImageURL.tmdb(image: movie.poster).urlString)
//            PosterImage(url: url, size: posterSize, title: movie.title, isDownsampling: true)
//                .matchedGeometryEffect(id: movie.id, in: namespace, properties: .frame, isSource: !showDetailView)
//                .onTapGesture {
//                    withAnimation(.easeInOut) {
//                        self.movie = movie
//                        showDetailView = true
//                    }
//                }
//        }
//        .frame(height: posterSize.height)
//        .padding(.bottom, 20)
