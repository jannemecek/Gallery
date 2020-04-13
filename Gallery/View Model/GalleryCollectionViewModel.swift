//
//  GalleryCollectionViewModel.swift
//  Gallery
//
//  Created by Jan Nemeček on 13/04/2020.
//  Copyright © 2020 Jan Nemecek. All rights reserved.
//

import UIKit

class GalleryCollectionViewModel: NSObject {
    var collectionView: UICollectionView
    var images: [Image]! {
        didSet {
            collectionView.reloadData()
        }
    }
    private let network: Network = Network()
    
    init(collectionView: UICollectionView) {
        self.collectionView = collectionView
        super.init()
        collectionView.dataSource = self
        collectionView.prefetchDataSource = self
        // TODO: register cell
        // TODO: add a caching layer
    }
    
    func loadImages() {
        // TODO: prettify
        network.images({ (images) in
            self.images = images
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func image(at indexPath: IndexPath) -> Image {
        return images[indexPath.item]
    }
}

// MARK: - UICollectionViewDataSource

extension GalleryCollectionViewModel: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ImageCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.configure(image(at: indexPath))
        return cell
    }
}

// MARK: - UICollectionViewDataSourcePrefetching

extension GalleryCollectionViewModel: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        indexPaths.map({image(at: $0)}).forEach({
            ImageLoader.shared.loadImage($0, success: { _ in })
        })
    }
}
