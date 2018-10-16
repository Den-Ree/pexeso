//
//  PhotosService.swift
//  Pexeso
//
//  Created by Den Ree on 10/10/2018.
//  Copyright © 2018 Den Ree. All rights reserved.
//

import UIKit

final class PhotosService {
  // MARK: - Properies
  fileprivate lazy var client: AnyNetworkClient = {
    return NetworkClient(PhotosService.baseURLPath, session: PhotosService.makeDefaultSession())
  }()
  fileprivate var currentTaskId: Int?
  // MARK: - Public
  func fetchPhotos(search: String, in page: Int, completion: @escaping AnyValueCompletionHandler<[UnsplashPhoto]>) {
    if let taskId = currentTaskId {
      client.cancelRequest(withTaskId: taskId)
    }
    let request = UnsplashRequest.searchPhotos(search: search, page: page)
    currentTaskId = client.send(request, completion: { (response: UnsplashResponse?, error: Error?) in
      if let error = error {
        
      }
    })
  }
}
fileprivate extension PhotosService {
  // MARK: - Private
  /// Den's comment: Bad practice, in real project I keep it in xcconfig
  static let baseURLPath = "https://api.unsplash.com/"
  /// Create default session for Unsplash API
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
    configuration.urlCache = cache
    // setup headers
    var headers = URLSessionConfiguration.default.httpAdditionalHeaders ?? [:]
    headers["Accept-Version"] = "v1"
    /// Den's comment: Bad practice, in real project I keep it in xcconfig
    headers["Authorization"] = "Client-ID 9ce03c378eaa16a91a09809b35a9f308f9eab0e5ecbf45544300e8c139341964"
    headers["contentType"] = "application/json"
    configuration.httpAdditionalHeaders = headers
    return URLSession(configuration: configuration)
  }
}
