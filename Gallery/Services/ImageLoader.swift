//
//  ImageLoader.swift
//  Gallery
//
//  Created by Jan Nemeček on 13/04/2020.
//  Copyright © 2020 Jan Nemecek. All rights reserved.
//

import UIKit

typealias ImageLoaderCompletion = (UIImage?) -> Void

final class ImageLoader {
    static let shared = ImageLoader()
    // Currently used as a cache for decoded images. Ideally, we would separate image cache and decoded image cache
    private let cache = ImageCache()
    private let network = Network()
    private var tasks: [IdType: Cancellable] = [:]
    private var loadQueue = DispatchQueue(label: "image_loader", qos: .background)
    private var resizeQueue = DispatchQueue(label: "resize")
    
    // Resizes the image to match the receiver for optimum performance
    @discardableResult
    func loadImage(_ image: CacheableImage, into view: UIImageView) -> Cancellable? {
        return loadImage(image) { [weak view] (result) in
            guard let result = result,
                let view = view else { return }
            let size = result.size.aspectFillSize(view.frame.size)
            self.resizeQueue.async {
                let image = result.scaled(to: size)
                DispatchQueue.main.async {
                    view.image = image
                }
            }
        }
    }
    
    // Return the original decoded image, ideal for usage in sharing context
    // TODO: prevent double loading of same image
    @discardableResult
    func loadImage(_ image: CacheableImage, success: @escaping ImageLoaderCompletion) -> Cancellable? {
        if let image = cache[image.id] {
            success(image)
            return nil
        }
        // TODO: check if we're already loading this image
//        guard tasks[image.id] == nil else {
//            // TODO: add this completion to execute after the original task is done
//        }
        return fetchImage(image, success: success)
    }
    
    private func fetchImage(_ image: CacheableImage, success: @escaping ImageLoaderCompletion) -> Cancellable? {
        // check if local image
        if image.url().isFileURL {
            loadQueue.async {
                self.loadLocalImage(image, success: success)
            }
            return nil
        }
        let task = network.downloadImageData(image, completion: { [weak self] (result) in
            defer { self?.tasks[image.id] = nil }
            guard let data = try? result.get() else { return }
            self?.loadQueue.async {
                let decodedImage = UIImage(data: data)?.decoded()
                self?.cache[image.id] = decodedImage
                DispatchQueue.main.async {
                    success(decodedImage)
                }
            }
        })
        tasks[image.id] = task
        return task
    }
    
    // TODO: wrap this in an operation to make it cancellable
    private func loadLocalImage(_ image: CacheableImage, success: @escaping ImageLoaderCompletion) {
        do {
            let directory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let url = directory.appendingPathComponent(image.id)
            let data = try Data(contentsOf: url)
            let localImage = UIImage(data: data)?.decoded()
            cache[image.id] = localImage
            DispatchQueue.main.async {
                success(localImage)
            }
        } catch {
            print(error.localizedDescription)
        }
    }

    func cancelLoad(_ image: CacheableImage) {
        tasks[image.id]?.cancel()
        tasks.removeValue(forKey: image.id)
    }
}
