//
//  GalleryCollectionViewModel.swift
//  Gallery
//
//  Created by Jan Nemeček on 13/04/2020.
//  Copyright © 2020 Jan Nemecek. All rights reserved.
//

import UIKit

class GalleryCollectionViewModel: NSObject {
    var images: [Image]! {
        didSet {
            collectionView.reloadData()
        }
    }
    fileprivate let imageLoader = ImageLoader.shared
    private let collectionView: UICollectionView
    private let database: Database = Database()
    private let network: Network = Network()
    
    init(collectionView: UICollectionView) {
        self.collectionView = collectionView
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
        // TODO: handle errors a bit better (ie. offline state)
        network.images { result in
            self.loadImages()
        }
    }
    
    func image(at indexPath: IndexPath) -> Image {
        return images[indexPath.item]
    }
    
    func insertImage(_ pickedImage: UIImage) {
        guard let data = pickedImage.pngData() else { return }
        // TODO: separate out image saving code
        let fileManager = FileManager.default
        do {
            // write file
            let directory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let id = UUID().uuidString
            let url = directory.appendingPathComponent(id)
            try data.write(to: url)
            
            // write to db
            let context = self.database.persistentContainer.newBackgroundContext()
            let image = Image(context: context)
            image.id = id
            image.picture = url.absoluteString
            try context.save()
            
            // show in view model
            if let viewImage: Image = database.persistentContainer.viewContext.object(with: image.objectID) as? Image {
                self.insertImage(viewImage)
            }
        } catch {
            print(error.localizedDescription)
        }
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
