//
//  Router.swift
//  Gallery
//
//  Created by Jan Nemeček on 13/04/2020.
//  Copyright © 2020 Jan Nemecek. All rights reserved.
//

import Foundation

enum Router: URLFactory {
    case images, image(CacheableImage)
    func url() -> URL {
        switch self {
        case .images:
            return URL(string: "https://www.json-generator.com/api/json/get/cftPFNNHsi")!
        case .image(let image):
            return URL(string: image.picture)!
        }
    }
}
