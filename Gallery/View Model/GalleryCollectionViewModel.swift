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
    fileprivate let imageLoader = ImageLoader.shared
    private let network: Network = Network()
    
    init(collectionView: UICollectionView) {
        self.collectionView = collectionView
        super.init()
        collectionView.dataSource = self
        collectionView.prefetchDataSource = self
        loadImages()
    }
    
    private func loadImages() {
        // TODO: persist in  DB
        // TODO: handle errors gracefully
        network.images { result in
            self.images = try? result.get()
        }
    }
    
    func image(at indexPath: IndexPath) -> Image {
        return images[indexPath.item]
    }
    
    func insertImage(_ pickedImage: UIImage) {
        // TODO: separate out image saving code
        let fileManager = FileManager.default
        do {
            let directory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let id = UUID().uuidString
            let url = directory.appendingPathComponent(id)
            try pickedImage.pngData()?.write(to: url)
            let image = Image(id: id, path: url.absoluteString)
            insertImage(image)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func insertImage(_ image: Image) {
        // TODO: add to image cache immediately
        let indexPath = IndexPath(item: 0, section: 0)
        images.insert(image, at: indexPath.item)
        collectionView.insertItems(at: [indexPath])
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
