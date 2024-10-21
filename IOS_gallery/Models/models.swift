//
//  models.swift
//  IOS_gallery
//
//  Created by hemanth on 10/20/24.
//

import Foundation

// MARK: - UnsplashImage Model
struct UnsplashImage: Decodable {
    let id: String
    let urls: ImageURLs
//    let liked_by_user:Bool
//    let description:String
}

struct ImageURLs: Decodable {
    let small: String?
    let full: String?
}


// Define SearchResult model
struct SearchResult: Decodable {
    let total:Int
    let total_pages:Int
    let results: [UnsplashImage]
}

