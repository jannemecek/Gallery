//
//  Network.swift
//  Gallery
//
//  Created by Jan Nemeček on 13/04/2020.
//  Copyright © 2020 Jan Nemecek. All rights reserved.
//

import Foundation

final class Network {
    private let session = URLSession(configuration: .default)
    
    @discardableResult
    func images(_ success: @escaping ([Image]) -> Void, failure: @escaping (Error) -> Void) -> Cancellable {
        // TODO: generalize this function to work with other routes and responses
        let task = session.dataTask(with: Router.images.url(), completionHandler: { data, _ , error in
            if let error = error {
                failure(error)
                return
            }
            guard let data = data else {
                // TODO: return mapping error
                return
            }
            // TODO: parse response if needed
            do {
                let decoder = JSONDecoder()
                let responseObject = try decoder.decode([Image].self, from: data)
                DispatchQueue.main.async {
                    success(responseObject)
                }
            } catch {
                failure(error)
            }
        })
        task.resume()
        return task
    }
    
    @discardableResult
    func downloadImageData(_ image: CacheableImage, success: @escaping (Data) -> Void, failure: @escaping (Error) -> Void) -> Cancellable {
        // TODO: generalize this function to work with other routes and responses
        let task = session.dataTask(with: Router.image(image).url(), completionHandler: { data, _ , error in
            if let error = error {
                failure(error)
                return
            }
            guard let data = data else {
                // TODO: return mapping error
                return
            }
            DispatchQueue.main.async {
                success(data)
            }
        })
        task.resume()
        return task
    }
}
