//
//  PagingView.swift
//  Film-in
//
//  Created by Minjae Kim on 12/17/24.
//

import SwiftUI
import Kingfisher

struct Temp: Hashable, Identifiable {
    let id = UUID()
    let data: Int
}

struct CustomPagingView: View {
    @State private var index = 0
    @State private var posterSize: CGSize = .zero
    @State private var cellSize: CGSize = .zero
    
    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                ScrollView {
                    VStack {
                        PagingView(currentIndex: $index, items: (0..<10).map { Temp(data: $0) }) { item in
                            NavigationLink {
                                EmptyView()
                            } label: {
                                let url = URL(string: ImageURL.tmdb(image: "/x2BHx02jMbvpKjMvbf8XxJkYwHJ.jpg").urlString)
                                PosterImage(url: url, size: posterSize, title: "", isDownsampling: true)
                            }
                        }
                        .frame(height: posterSize.height) // 높이 설정
                        .border(.red)
                        
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach((0..<10)) { _ in
                                    Rectangle()
                                        .frame(width: cellSize.width, height: cellSize.height)
                                }
                            }
                        }
                    }
                }
                .task {
                    if posterSize == .zero {
                        posterSize = CGSize(width: proxy.size.width * 0.7, height: proxy.size.width * 0.7 * 1.5)
                    }
                    
                    if cellSize == .zero {
                        cellSize = CGSize(
                            width: posterSize.width * 0.5,
                            height: posterSize.height * 0.5
                        )
                    }
                }
            }
        }
    }
}

struct PagingView<Item: Hashable, Content: View>: UIViewRepresentable {
    @Binding var currentIndex: Int
    let items: [Item]
    let spacing: CGFloat?
    var content: (Item) -> Content
    
    init(
        currentIndex: Binding<Int>,
        items: [Item],
        spacing: CGFloat? = 0,
        @ViewBuilder content: @escaping (Item) -> Content
    ) {
        self._currentIndex = currentIndex
        self.items = items
        self.spacing = spacing
        self.content = content
    }
     
    func createLayout() -> UICollectionViewLayout {
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: spacing ?? 0, bottom: 0, trailing: spacing ?? 0)
        
        let containerGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.80),
                                               heightDimension: .fractionalHeight(1.0)),
            subitems: [item])
        
        let section = NSCollectionLayoutSection(group: containerGroup)
        section.orthogonalScrollingBehavior = .groupPagingCentered
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    func makeUIView(context: Context) -> UICollectionView {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceVertical = false
        collectionView.delegate = context.coordinator
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        context.coordinator.configureDataSource(for: collectionView)
        return collectionView
    }
    
    func updateUIView(_ uiView: UICollectionView, context: Context) {
        context.coordinator.parent = self
        context.coordinator.applySnapshot()
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UICollectionViewDelegateFlowLayout {
        var parent: PagingView
        var dataSource: UICollectionViewDiffableDataSource<Int, Item>!
        
        init(_ parent: PagingView) {
            self.parent = parent
        }
        
        func configureDataSource(for collectionView: UICollectionView) {
            let cellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, Item> { cell, indexPath, identifier in
                cell.contentConfiguration = UIHostingConfiguration { [weak self] in
                    self?.parent.content(identifier)
                }
            }
            
            dataSource = UICollectionViewDiffableDataSource<Int, Item>(collectionView: collectionView) { collectionView, indexPath, item in
                return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
            }
            
            applySnapshot()
        }
        
        func applySnapshot() {
            var snapshot = NSDiffableDataSourceSnapshot<Int, Item>()
            snapshot.appendSections([0])
            snapshot.appendItems(parent.items)
            dataSource.apply(snapshot, animatingDifferences: true)
        }
        
        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            let page = Int(scrollView.contentOffset.x / scrollView.bounds.width)
            parent.currentIndex = page
        }
    }
}

#Preview {
    CustomPagingView()
}
