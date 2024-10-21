//
//  imagesViewModel.swift
//  IOS_gallery
//
//  Created by hemanth on 10/20/24.
//

import Foundation

class ImageGalleryViewModel {
    private let ACCESS_KEY = "OCBSbJJXl__Bvt3iUCBL8FUSCGWIrt0_zWLQ48_HBqM"
    private let unsplashURL = "https://api.unsplash.com/"
    
    var searchQuery: String = ""   // Current search query
    var currentPage = 1
    private let perPage = 20
    var images: [UnsplashImage] = []
    var onDataFetched: (() -> Void)?
    
    var isFetchingMore = false  // To avoid multiple fetches

    // Helper function to build URLs
    private func buildURL(endpoint: String, parameters: [String: String]) -> URL? {
        var urlComponents = URLComponents(string: "\(unsplashURL)\(endpoint)")
        urlComponents?.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        return urlComponents?.url
    }

    // Regular image fetch (pagination support)
    func fetchImages() async {
        guard !isFetchingMore else { return }
        isFetchingMore = true

        if let url = buildURL(endpoint: "photos", parameters: [
            "client_id": ACCESS_KEY,
            "page": "\(currentPage)",
            "per_page": "\(perPage)"
        ]) {
            await fetchData(from: url)
        }

        isFetchingMore = false
    }
    
    // Search images (pagination support)
    func searchImages(search text: String) async {
        guard !isFetchingMore else { return }
        isFetchingMore = true
        
        if let url = buildURL(endpoint: "search/photos", parameters: [
            "client_id": ACCESS_KEY,
            "query": text,
            "page": "\(currentPage)"
        ]) {
            await fetchData(from: url, isSearch: true)
        }

        isFetchingMore = false
    }

    private func fetchData(from url: URL, isSearch: Bool = false) async {
        
        print(url)
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if isSearch {
                let searchResult = try JSONDecoder().decode(SearchResult.self, from: data)
                self.images.append(contentsOf: searchResult.results)  // Append new search results
            } else {
                let fetchedImages = try JSONDecoder().decode([UnsplashImage].self, from: data)
                self.images.append(contentsOf: fetchedImages)
            }
            self.currentPage += 1  // Increment the page for next results
            
            DispatchQueue.main.async { [weak self] in
                self?.onDataFetched?()
            }
        } catch {
            print("Error fetching images: \(error.localizedDescription)")
        }
    }

    // Reset for new search or pull-to-refresh
    func resetSearch() {
        currentPage = 1
        images.removeAll()  // Clear existing images
    }
}
