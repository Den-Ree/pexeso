//
//  NetworkClient.swift
//  Pexeso
//
//  Created by Den Ree on 10/10/2018.
//  Copyright © 2018 Den Ree. All rights reserved.
//

import Foundation

protocol AnyNetworkRequest {
  var path: String { get }
  var parameters: [String: String] { get }
}

protocol AnyNetworkResponse: Codable {}

enum NetworkError: Error {
  case badRequestPath
  case emptyResponse
}

protocol AnyNetworkClient {
  func send<Response: AnyNetworkResponse>(_ request: AnyNetworkRequest, completion: @escaping (Response?, Error?) -> Void) -> Int?
  func fetchData(from path: String, completion: @escaping (Data?, Error?) -> Void) -> Int?
  func cancelRequest(withTaskId taskId: Int)
}

final class NetworkClient: AnyNetworkClient {
  // MARK: - Properties
  fileprivate let baseURLPath: String
  fileprivate let session: URLSession
  // MARK: - Init
  required init(_ baseURLPath: String, session: URLSession = URLSession.shared) {
    self.baseURLPath = baseURLPath
    self.session = session
  }
  // MARK: - Public
  /// Generic method to send any request
  ///
  /// - Parameters:
  ///   - request: api request, which contains path and paramters, if needed.
  ///   - completion: a block, which is called when obtains a response
  /// - Returns: downloading task id
  func send<Response: AnyNetworkResponse>(_ request: AnyNetworkRequest, completion: @escaping (Response?, Error?) -> Void) -> Int? {
    // create url components
    guard var urlComponenets = URLComponents(string: baseURLPath) else {
      completion(nil, NetworkError.badRequestPath)
      return nil
    }
    urlComponenets.path = request.path
    urlComponenets.queryItems = request.parameters.map { (parameter) -> URLQueryItem in
      return URLQueryItem(name: parameter.key, value: parameter.value)
    }
    guard let url = urlComponenets.url else {
      completion(nil, NetworkError.badRequestPath)
      return nil
    }
    // create request task
    let dataTask = session.dataTask(with: url, completionHandler: { (data, response, error) in
      if let error = error {
        completion(nil, error)
        return
      }
      guard let data = data else {
        completion(nil, NetworkError.emptyResponse)
        return
      }
      // parsing response
      DispatchQueue.global(qos: .background).async {
        do {
          let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
          print("\(jsonObject)")
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
  /// Method to fetch image's data from url
  ///
  /// - Parameters:
  ///   - path: a url path to the image
  ///   - completion: a block, which is called when obtains a response
  /// - Returns: downloading task id
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
  func cancelRequest(withTaskId taskId: Int) {
    session.getAllTasks { (tasks) in
      if let canceledTask = tasks.first(where: {$0.taskIdentifier == taskId}) {
        canceledTask.cancel()
      }
    }
  }
}
