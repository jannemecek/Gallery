//
//  ImageCollectionViewCell.swift
//  Gallery
//
//  Created by Jan Nemeček on 13/04/2020.
//  Copyright © 2020 Jan Nemecek. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell, ReusableCell {
    static var reuseIdentifier: String {
        "Cell"
    }
    @IBOutlet weak var imageView: UIImageView!
    private var disposable: Cancellable?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposable?.cancel()
        imageView.image = nil
    }
    
    func configure(_ image: Image, loader: ImageLoader) {
        disposable = loader.loadImage(image) { [weak self] (image) in
            self?.imageView.image = image
        }
    }
}
