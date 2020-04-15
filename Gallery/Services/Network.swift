//
//  Network.swift
//  Gallery
//
//  Created by Jan Nemeček on 13/04/2020.
//  Copyright © 2020 Jan Nemecek. All rights reserved.
//

import Foundation

final class Network {
    private let session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.waitsForConnectivity = true
        configuration.requestCachePolicy = .returnCacheDataElseLoad
        let session = URLSession(configuration: configuration)
        return session
    }()
    
    @discardableResult
    func images(_ completion: @escaping (Result<[Image], Error>) -> Void) -> Cancellable {
        // TODO: generalize this function to work with other routes and responses
        let task = session.dataTask(with: Router.images.url(), completionHandler: { data, _ , error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                // TODO: return mapping error
                return
            }
            do {
                let decoder = JSONDecoder()
                let responseObject = try decoder.decode([Image].self, from: data)
                DispatchQueue.main.async {
                    completion(.success(responseObject))
                }
            } catch {
                completion(.failure(error))
            }
        })
        task.resume()
        return task
    }
    
    @discardableResult
    func downloadImageData(_ image: CacheableImage, completion: @escaping (Result<Data, Error>) -> Void) -> Cancellable {
        // TODO: generalize this function to work with other routes and responses
        let task = session.dataTask(with: Router.image(image).url(), completionHandler: { data, _ , error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                // TODO: return mapping error
                return
            }
            DispatchQueue.main.async {
                completion(.success(data))
            }
        })
        task.resume()
        return task
    }
}
