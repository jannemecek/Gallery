//
//  Database+Files.swift
//  Gallery
//
//  Created by Jan Nemeček on 15/04/2020.
//  Copyright © 2020 Jan Nemecek. All rights reserved.
//

import Foundation
import CoreData

extension Database {
    // Ideally, we should abstract this so we don't work directly with Image model but some generic that only holds the ID and URL
    func insertData(_ data: Data) -> NSManagedObjectID? {
        let fileManager = FileManager.default
        do {
            // write file so we can store a reference in CD
            let directory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let id = UUID().uuidString
            let url = directory.appendingPathComponent(id)
            try data.write(to: url)
            
            // write to db
            let context = persistentContainer.newBackgroundContext()
            let image = Image(context: context)
            image.id = id
            image.picture = url.absoluteString
            try context.save()
            return image.objectID
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}
