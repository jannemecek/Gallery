//
//  Image.swift
//  Gallery
//
//  Created by Jan Nemeček on 13/04/2020.
//  Copyright © 2020 Jan Nemecek. All rights reserved.
//

import Foundation

protocol CacheableImage {
    var id: IdType { get }
    var picture: String { get }
}

class Image: Codable, CacheableImage {
    let id: String
    let picture: String
    let comment, publishedAt, title: String?

    enum CodingKeys: String, CodingKey {
        case comment, picture
        case id = "_id"
        case publishedAt, title
    }
    
    init(id: String, path: String) {
        self.id = id
        self.picture = path
        self.comment = nil
        self.publishedAt = nil
        self.title = nil
    }
}
