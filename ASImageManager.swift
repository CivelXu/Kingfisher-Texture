//
//  ASImageManager.swift
//
//  Created by xuxiwen on 2018/6/25.
//  Copyright © 2018年 xuxiwen. All rights reserved.
//

import Kingfisher

extension ASNetworkImageNode {
    static func imageNode() -> ASNetworkImageNode {
        ImageDownloader.default.downloadTimeout = 30.0
        let imageNode = ASNetworkImageNode(cache: ASImageManager.shared,
                                           downloader: ASImageManager.shared)
        return imageNode
    }
}


class ASImageManager: NSObject, ASImageDownloaderProtocol, ASImageCacheProtocol {
    
    static let shared = ASImageManager.init()
    private override init(){}
    
    // MARK: - ASImageDownloaderProtocol
    
    func downloadImage(with URL: URL, callbackQueue: DispatchQueue, downloadProgress: ASImageDownloaderProgress?, completion: @escaping ASImageDownloaderCompletion) -> Any? {
        
        var operation: RetrieveImageDownloadTask?
        operation = ImageDownloader.default.downloadImage(with: URL, progressBlock: { (received, expected) in
            if downloadProgress != nil {
                callbackQueue.async(execute: {
                    let progress = expected == 0 ? 0 : received / expected
                    downloadProgress?(CGFloat(progress))
                })
            }
        }) { (image, error, url, data) in
            // Already download image file
            if image != nil {
                callbackQueue.async(execute: { completion(image, error, nil, url) })
                // async
                ImageCache.default.store(image!, original: data, forKey: URL.cacheKey, toDisk: true)
            }
        }
        return operation
    }
    
    
    func cancelImageDownload(forIdentifier downloadIdentifier: Any) {
        // Cancel download task
        if let task = downloadIdentifier as? RetrieveImageDownloadTask  {
            task.cancel()
        }
    }
    
    
    // MARK: - ASImageCacheProtocol

    func cachedImage(with URL: URL, callbackQueue: DispatchQueue, completion: @escaping ASImageCacherCompletion) {
        // Get image by cache
        ImageCache.default.retrieveImage(forKey: URL.cacheKey, options: nil) { (img, _) in
            callbackQueue.async { completion(img) }
        }
    }
    
    func synchronouslyFetchedCachedImage(with URL: URL) -> ASImageContainerProtocol? {
        return KingfisherContainer(url: URL)
    }
    
    func clearFetchedImageFromCache(with URL: URL) {
        // clear FetchedImage From Memory Cache
        ImageCache.default.removeImage(forKey: URL.cacheKey,
                                       fromMemory: true,
                                       fromDisk: false) {
            
        }
    }

}

// MARK: - ASImageContainerProtocol

class KingfisherContainer: NSObject, ASImageContainerProtocol {
    
    var image: UIImage?
    
    init(url: URL) {
        super.init()
        self.image =  ImageCache.default.retrieveImageInMemoryCache(forKey: url.cacheKey)
    }

    func asdk_image() -> UIImage? {
        return image
    }
    
    func asdk_animatedImageData() -> Data? {
        return nil
    }
    
    
}
