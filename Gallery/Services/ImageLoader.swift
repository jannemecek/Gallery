//
//  ImageLoader.swift
//  Gallery
//
//  Created by Jan Nemeček on 13/04/2020.
//  Copyright © 2020 Jan Nemecek. All rights reserved.
//

import Foundation
import class UIKit.UIImage

final class ImageLoader {
    static let shared = ImageLoader()
    private let cache = ImageCache()
    private let network = Network()
    
    // TODO: add canceling pending requests, prevent double loading of same image
    @discardableResult
    func loadImage(_ image: CacheableImage, success: @escaping (UIImage?) -> Void) -> Cancellable? {
        if let image = cache[image.id] {
            success(image)
            return nil
        }
        return network.downloadImageData(image, success: { [weak self] (data) in
            let decodedImage = UIImage(data: data)
            self?.cache[image.id] = decodedImage
            success(decodedImage)
        }, failure: { _ in })
    }
}
