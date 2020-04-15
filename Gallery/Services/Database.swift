//
//  Database.swift
//  Gallery
//
//  Created by Jan Nemeček on 15/04/2020.
//  Copyright © 2020 Jan Nemecek. All rights reserved.
//

import Foundation
import CoreData

class Database {
    // MARK: - Core Data
    
    private let queue = DispatchQueue(label: "database")
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Gallery")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func objects<T: NSManagedObject>() -> [T]? {
        let request: NSFetchRequest<T> = NSFetchRequest(entityName: String(describing: T.self))
        let objects: [T]? = try? persistentContainer.viewContext.fetch(request)
        return objects
    }
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                print(nsError.localizedDescription)
            }
        }
    }
}

// Neccessary to pass DB context during mapping phase
extension CodingUserInfoKey {
    static let context = CodingUserInfoKey(rawValue: "dbContext")
}
