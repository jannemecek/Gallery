//
//  ImageCache.swift
//  Gallery
//
//  Created by Jan Nemeček on 13/04/2020.
//  Copyright © 2020 Jan Nemecek. All rights reserved.
//

import Foundation
import class UIKit.UIImage

typealias IdType = String

final class ImageCache {
    private lazy var imageCache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        return cache
    }()
    
    subscript(_ key: IdType) -> UIImage? {
        get {
            return imageCache.object(forKey: key as NSString)
        }
        set {
            let key = key as NSString
            guard let value = newValue else {
                imageCache.removeObject(forKey: key)
                return
            }
            imageCache.setObject(value, forKey: key)
        }
    }
}
