//
//  UnsplashResponse.swift
//  Pexeso
//
//  Created by Den Ree on 10/10/2018.
//  Copyright © 2018 Den Ree. All rights reserved.
//

import UIKit
/// Den's comment: Parse only needed values 
final class UnsplashResponse: AnyNetworkResponse {
  // MARK: - Properties
  var total: Int
  var results: [UnsplashPhoto]
}

final class UnsplashPhoto: Codable {
  // MARK: - Properties
  var id: String
  var urls: Url
  // MARK: - Nested
  struct Url: Codable {
    let raw: String
    let full: String
    let regular: String
    let small: String
    let thumb: String
  }
}
