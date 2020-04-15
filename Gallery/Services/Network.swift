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
        return fetchData(Router.images) { (result) in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let context = Database().persistentContainer.newBackgroundContext()
                    decoder.userInfo[CodingUserInfoKey.context!] = context
                    let responseObject = try decoder.decode([Image].self, from: data)
                    try context.save()
                    DispatchQueue.main.async {
                        completion(.success(responseObject))
                    }
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    @discardableResult
    func downloadImageData(_ image: CacheableImage, completion: @escaping (Result<Data, Error>) -> Void) -> Cancellable {
        return fetchData(Router.image(image), completion: completion)
    }
    
    @discardableResult
    private func fetchData(_ route: URLFactory, completion: @escaping (Result<Data, Error>) -> Void) -> Cancellable {
        let task = session.dataTask(with: route.url(), completionHandler: { data, _ , error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else { fatalError() }
            DispatchQueue.main.async {
                completion(.success(data))
            }
        })
        task.resume()
        return task
    }
}
