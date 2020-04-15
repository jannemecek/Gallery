//
//  Image+CoreDataClass.swift
//  Gallery
//
//  Created by Jan Nemeček on 15/04/2020.
//  Copyright © 2020 Jan Nemecek. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Image)
public class Image: NSManagedObject, Decodable, CacheableImage {
    enum CodingKeys: String, CodingKey {
        case comment, picture
        case id = "_id"
        case publishedAt, title
    }
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Image> {
        return NSFetchRequest<Image>(entityName: "Image")
    }

    @NSManaged public var comment: String?
    @NSManaged public var id: String!
    @NSManaged public var picture: String!
    @NSManaged public var title: String?
    
    required convenience public init(from decoder: Decoder) throws {
        guard let key = CodingUserInfoKey.context,
            let context = decoder.userInfo[key] as? NSManagedObjectContext,
            let entity = NSEntityDescription.entity(forEntityName: String(describing: type(of: self)), in: context) else { fatalError() }
        self.init(entity: entity, insertInto: context)
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try values.decode(String.self, forKey: .id)
        self.picture = try values.decode(String.self, forKey: .picture)
        self.title = try values.decodeIfPresent(String.self, forKey: .title)
        self.comment = try values.decodeIfPresent(String.self, forKey: .comment)
    }
}

// MARK: - Encodable

extension Image: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.picture, forKey: .picture)
        try container.encodeIfPresent(self.comment, forKey: .comment)
        try container.encodeIfPresent(self.title, forKey: .title)
    }
}
