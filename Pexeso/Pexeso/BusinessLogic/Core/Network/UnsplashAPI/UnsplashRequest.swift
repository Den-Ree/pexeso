//
//  UnsplashRequest.swift
//  Pexeso
//
//  Created by Den Ree on 10/10/2018.
//  Copyright © 2018 Den Ree. All rights reserved.
//

import UIKit

enum UnsplashRequest: AnyNetworkRequest {
  case searchPhotos(search: String, page: Int)
}

extension UnsplashRequest {
  var path: String {
    switch self {
    case .searchPhotos:
      return "/search/photos"
    }
  }
  var parameters: [String: String] {
    switch self {
    case let .searchPhotos(search, page):
      return [
        "query": search,
        "page": String(page),
        "per_page": String(30)
      ]
    }
  }
}
