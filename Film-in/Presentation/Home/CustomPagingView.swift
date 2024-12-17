//
//  CustomPagingView.swift
//  Film-in
//
//  Created by Minjae Kim on 12/17/24.
//

import SwiftUI

struct Temp: Hashable, Identifiable {
    let id = UUID()
    let data: Int
}

struct CustomPagingView: View {
    @State private var index = 0
    @State private var selectedItem: Temp?
    
    var body: some View {
        NavigationStack {
            PagingCollectionView(currentIndex: $index, items: (0..<10).map { Temp(data: $0) }) { item in
                selectedItem = item
            } content: { item in
                switch item.data {
                case 0: Rectangle().foregroundStyle(.red)
                case 1: Rectangle().foregroundStyle(.blue)
                case 2: Rectangle().foregroundStyle(.green)
                case 3: Rectangle().foregroundStyle(.yellow)
                case 4: Rectangle().foregroundStyle(.cyan)
                default: Rectangle().foregroundStyle(.brown)
                }
            }
            .frame(height: 400) // 높이 설정
            .navigationDestination(isPresented: Binding(get: {
                selectedItem != nil
            }, set: { isActive in
                if !isActive { selectedItem = nil }
            })) {
                EmptyView()
                    .onAppear {
                        print("onAppear")
                    }
                    .onDisappear {
                        print("onDisappear")
                    }
            }
        }
    }
}

struct PagingCollectionView<Item: Hashable, Content: View>: UIViewRepresentable {
    @Binding var currentIndex: Int
    let items: [Item]
    let spacing: CGFloat?
    var onSelect: ((Item) -> Void)?
    var content: (Item) -> Content
    
    init(
        currentIndex: Binding<Int>,
        items: [Item],
        spacing: CGFloat? = 0,
        onSelect: ((Item) -> Void)? = nil,
        @ViewBuilder content: @escaping (Item) -> Content
    ) {
        self._currentIndex = currentIndex
        self.items = items
        self.spacing = spacing
        self.onSelect = onSelect
        self.content = content
    }
    
    func createLayout() -> UICollectionViewLayout {
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
        item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: spacing ?? 0, bottom: 10, trailing: spacing ?? 0)
        
        let containerGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.85),
                                               heightDimension: .fractionalHeight(1.0)),
            subitems: [item])
        
        let section = NSCollectionLayoutSection(group: containerGroup)
        section.orthogonalScrollingBehavior = .groupPagingCentered
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    func makeUIView(context: Context) -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width * 0.8, height: 400) // 셀 크기 설정
        layout.minimumLineSpacing = 12 // 셀 간 간격

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = context.coordinator
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        context.coordinator.configureDataSource(for: collectionView)
        return collectionView
    }
    
    func updateUIView(_ uiView: UICollectionView, context: Context) {
        context.coordinator.applySnapshot()
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UICollectionViewDelegateFlowLayout {
        var parent: PagingCollectionView
        var dataSource: UICollectionViewDiffableDataSource<Int, Item>!
        
        init(_ parent: PagingCollectionView) {
            self.parent = parent
        }
        
        // DiffableDataSource 구성
        func configureDataSource(for collectionView: UICollectionView) {
            dataSource = UICollectionViewDiffableDataSource<Int, Item>(collectionView: collectionView) { collectionView, indexPath, item in
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
                cell.contentConfiguration = UIHostingConfiguration {
                    self.parent.content(item)
                }
                return cell
            }
            
            applySnapshot()
        }
        
        func applySnapshot() {
            var snapshot = NSDiffableDataSourceSnapshot<Int, Item>()
            snapshot.appendSections([0])
            snapshot.appendItems(parent.items)
            dataSource.apply(snapshot, animatingDifferences: true)
        }
        
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            parent.onSelect?(parent.items[indexPath.item])
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
