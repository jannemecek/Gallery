//
//  GalleryCollectionViewModel.swift
//  Gallery
//
//  Created by Jan Nemeček on 13/04/2020.
//  Copyright © 2020 Jan Nemecek. All rights reserved.
//

import UIKit

final class GalleryCollectionViewModel: NSObject {
    var images: [Image]! {
        didSet {
            collectionView.reloadData()
        }
    }
    fileprivate let imageLoader = ImageLoader.shared
    private let collectionView: UICollectionView
    private let statusLabel: UILabel
    private let database: Database = Database()
    private let network: Network = Network()
    
    init(collectionView: UICollectionView, statusLabel: UILabel) {
        self.collectionView = collectionView
        self.statusLabel = statusLabel
        super.init()
        collectionView.dataSource = self
        collectionView.prefetchDataSource = self
        loadImages()
    }
    
    private func loadImages() {
        // check if we've already fetched images
        // TODO: check if we should also call API if we have data
        if let images: [Image] = database.objects(),
            !images.isEmpty {
            self.images = images
            return
        }
        network.images { [weak self] result in
            switch result {
            case .success(let images):
                guard !images.isEmpty else { return }
                self?.loadImages()
            case .failure(let error):
                self?.statusLabel.text = error.localizedDescription
            }
        }
    }
    
    func image(at indexPath: IndexPath) -> Image {
        return images[indexPath.item]
    }
    
    func insertImage(_ pickedImage: UIImage) {
        guard let data = pickedImage.fixedOrientation()?.pngData(),
            let id = database.insertData(data),
            let viewImage: Image = database.persistentContainer.viewContext.object(with: id) as? Image else { return }
        insertImage(viewImage)
    }
    
    func insertImage(_ image: Image) {
        let indexPath = IndexPath(item: images.count, section: 0)
        collectionView.performBatchUpdates({
            self.images.append(image)
            self.collectionView.insertItems(at: [indexPath])
        }, completion: { (_) in
            self.collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
        })
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
        cell.configure(image(at: indexPath), loader: imageLoader)
        return cell
    }
}

// MARK: - UICollectionViewDataSourcePrefetching

extension GalleryCollectionViewModel: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        indexPaths.map({image(at: $0)}).forEach({
            imageLoader.loadImage($0, success: { _ in })
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        indexPaths.map({image(at: $0)}).forEach({
            imageLoader.cancelLoad($0)
        })
    }
}
