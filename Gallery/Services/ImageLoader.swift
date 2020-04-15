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
    private var tasks: [IdType: Cancellable] = [:]
    
    // TODO: prevent double loading of same image
    @discardableResult
    func loadImage(_ image: CacheableImage, success: @escaping (UIImage?) -> Void) -> Cancellable? {
        if let image = cache[image.id] {
            success(image)
            return nil
        }
        // TODO: check if we have it in disk cache
        
        // TODO: check if we're already loading this image
//        guard tasks[image.id] == nil else {
//            // TODO: add this completion to execute after it's done
//        }
        let task = network.downloadImageData(image, completion: { [weak self] (result) in
            defer { self?.tasks[image.id] = nil }
            guard let data = try? result.get() else { return }
            let decodedImage = UIImage(data: data)
            self?.cache[image.id] = decodedImage
            success(decodedImage)
        })
        tasks[image.id] = task
        return task
    }
    
    func cancelLoad(_ image: CacheableImage) {
        tasks[image.id]?.cancel()
        tasks.removeValue(forKey: image.id)
    }
}
