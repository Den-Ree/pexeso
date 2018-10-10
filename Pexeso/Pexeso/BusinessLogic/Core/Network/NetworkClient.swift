//
//  NetworkClient.swift
//  Pexeso
//
//  Created by Den Ree on 10/10/2018.
//  Copyright © 2018 Den Ree. All rights reserved.
//

import Foundation

protocol AnyNetworkRequest {
  var path: String {get}
}

protocol AnyNetworkResponse: Codable {}

enum NetworkError: Error {
  case badRequestPath
}

protocol AnyNetworkService {
  func send<Response: AnyNetworkResponse>(_ request: AnyNetworkRequest, completion: @escaping (Response?, Error?) -> Void) -> Int?
  func fetchData(from path: String, completion: @escaping (Data?, Error?) -> Void) -> Int?
}

final class NetworkService {
  // MARK: - Properties
  fileprivate let baseURLPath: String
  fileprivate let session: URLSession
  // MARK: - Init
  required init(_ baseURLPath: String, session: URLSession = NetworkService.makeDefaultSession()) {
    self.baseURLPath = baseURLPath
    self.session = session
  }
  // MARK: - Public
  func send<Response: AnyNetworkResponse>(_ request: AnyNetworkRequest, completion: @escaping (Response?, Error?) -> Void) -> Int? {
    guard let url = URL(string: baseURLPath + request.path) else {
      completion(nil, NetworkError.badRequestPath)
      return nil
    }
    // create request task
    let dataTask = session.dataTask(with: url, completionHandler: { (data, response, error) in
      guard let data = data else {
        completion(nil, error)
        return
      }
      // parsing response
      DispatchQueue.global(qos: .background).async {
        do {
          let result = try JSONDecoder().decode(Response.self, from: data)
          completion(result, nil)
        } catch {
          DispatchQueue.main.async {
            completion(nil, error as NSError?)
          }
        }
      }
    })
    dataTask.resume()
    return dataTask.taskIdentifier
  }
  func fetchData(from path: String, completion: @escaping (Data?, Error?) -> Void) -> Int? {
    guard let url = URL(string: path) else {
      completion(nil, nil)
      return nil
    }
    let dataTask = session.dataTask(with: url, completionHandler: { (data, response, error) in
      completion(data, error)
    })
    dataTask.resume()
    return dataTask.taskIdentifier
  }
}

fileprivate extension NetworkService {
  // MARK: - Private
  /// Create default session with cache
  ///
  /// - Returns: session, which can be used for network requests
  static func makeDefaultSession() -> URLSession {
    let configuration = URLSessionConfiguration.default
    configuration.requestCachePolicy = .returnCacheDataElseLoad
    configuration.timeoutIntervalForRequest = 15
    // setup cache size
    let cacheSizeMemory = 10 * (1024 * 1024)
    let cacheSizeDisk = 50 * (1024 * 1024)
    let cache = URLCache(memoryCapacity: cacheSizeMemory, diskCapacity: cacheSizeDisk, diskPath: "networkclientcache")
    configuration.httpAdditionalHeaders = URLSessionConfiguration.default.httpAdditionalHeaders
    configuration.urlCache = cache
    return URLSession(configuration: configuration)
  }
}
