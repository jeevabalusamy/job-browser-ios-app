//
//  CachedAsyncImage.swift
//  JobBrowser
//

import SwiftUI

class ImageCache {
    static let shared = ImageCache()
    private var cache = NSCache<NSURL, UIImage>()
    
    private init() {
        // limit cache size if needed, e.g. cache.countLimit = 100
        cache.countLimit = 200
    }
    
    func set(_ image: UIImage, for url: URL) {
        cache.setObject(image, forKey: url as NSURL)
    }
    
    func get(for url: URL) -> UIImage? {
        return cache.object(forKey: url as NSURL)
    }
}

struct CachedAsyncImage<Content: View>: View {
    private let url: URL?
    private let content: (AsyncImagePhase) -> Content
    
    @State private var phase: AsyncImagePhase
    
    init(url: URL?, @ViewBuilder content: @escaping (AsyncImagePhase) -> Content) {
        self.url = url
        self.content = content
        self._phase = State(initialValue: .empty)
    }
    
    var body: some View {
        content(phase)
            .task(id: url) {
                await loadImage()
            }
    }
    
    private func loadImage() async {
        guard let url = url else {
            phase = .empty
            return
        }
        
        if let cachedImage = ImageCache.shared.get(for: url) {
            phase = .success(Image(uiImage: cachedImage))
            return
        }
        
        phase = .empty
        
        do {
            let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode,
               let uiImage = UIImage(data: data) {
                ImageCache.shared.set(uiImage, for: url)
                phase = .success(Image(uiImage: uiImage))
            } else {
                phase = .failure(URLError(.badServerResponse))
            }
        } catch {
            if (error as? URLError)?.code == .cancelled {
                // Task was cancelled, do nothing
            } else {
                phase = .failure(error)
            }
        }
    }
}
