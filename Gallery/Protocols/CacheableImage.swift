//
//  CacheableImage.swift
//  Gallery
//
//  Created by Jan Nemeček on 15/04/2020.
//  Copyright © 2020 Jan Nemecek. All rights reserved.
//

import Foundation

protocol CacheableImage {
    var id: IdType! { get }
    var picture: String! { get }
}

extension CacheableImage {
    func url() -> URL {
        return URL(string: picture)!
    }
}
