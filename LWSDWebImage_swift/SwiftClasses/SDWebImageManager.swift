/*
 * This file is part of the SDWebImage package.
 * Swift/SwiftUI version
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import Foundation
import UIKit

// MARK: - Manager Delegate Protocol

public protocol SDWebImageManagerDelegate: AnyObject {
    /// Controls which image should be downloaded when the image is not found in the cache
    func imageManager(_ imageManager: SDWebImageManager, shouldDownloadImageFor imageURL: URL?) -> Bool

    /// Allows to transform the image immediately after it has been downloaded and just before to cache it
    func imageManager(_ imageManager: SDWebImageManager, transformDownloadedImage image: UIImage?, with imageURL: URL?) -> UIImage?
}

// Make delegate methods optional
public extension SDWebImageManagerDelegate {
    func imageManager(_ imageManager: SDWebImageManager, shouldDownloadImageFor imageURL: URL?) -> Bool {
        return true
    }

    func imageManager(_ imageManager: SDWebImageManager, transformDownloadedImage image: UIImage?, with imageURL: URL?) -> UIImage? {
        return image
    }
}

// MARK: - Combined Operation

private class SDWebImageCombinedOperation: NSObject, SDWebImageOperation {
    var cancelled: Bool = false
    var cacheOperation: Operation?
    var downloadToken: SDWebImageDownloadToken?

    func cancel() {
        cancelled = true
        cacheOperation?.cancel()
        cacheOperation = nil

        if let token = downloadToken {
            SDWebImageDownloader.shared.cancel(token)
        }
        downloadToken = nil
    }
}

// MARK: - Web Image Manager

/// The SDWebImageManager is the class behind the UIImageView+WebCache category.
/// It ties the asynchronous downloader with the image cache store.
public class SDWebImageManager: NSObject {

    // MARK: - Properties

    public weak var delegate: SDWebImageManagerDelegate?

    public let imageCache: SDImageCache
    public let imageDownloader: SDWebImageDownloader

    /// The cache filter is a block used each time SDWebImageManager needs to convert a URL into a cache key
    public var cacheKeyFilter: SDWebImageCacheKeyFilterBlock?

    // MARK: - Private Properties

    private var failedURLs = Set<URL>()
    private var runningOperations = [SDWebImageCombinedOperation]()
    private let failedURLsLock = NSLock()
    private let runningOperationsLock = NSLock()

    // MARK: - Singleton

    public static let shared = SDWebImageManager()

    // MARK: - Initialization

    public convenience override init() {
        self.init(cache: SDImageCache.shared, downloader: SDWebImageDownloader.shared)
    }

    public init(cache: SDImageCache, downloader: SDWebImageDownloader) {
        self.imageCache = cache
        self.imageDownloader = downloader
        super.init()
    }

    // MARK: - Image Loading

    @discardableResult
    public func loadImage(
        with url: URL?,
        options: SDWebImageOptions = [],
        progress progressBlock: SDWebImageDownloaderProgressBlock? = nil,
        completed completedBlock: SDInternalCompletionBlock?
    ) -> SDWebImageOperation? {
        guard let url = url else {
            completedBlock?(nil, nil, NSError(domain: SDWebImageErrorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey: "URL is nil"]), .none, true, nil)
            return nil
        }

        // Prevent app crashing on invalid URL
        if url.absoluteString.isEmpty {
            completedBlock?(nil, nil, NSError(domain: SDWebImageErrorDomain, code: -2, userInfo: [NSLocalizedDescriptionKey: "URL is invalid"]), .none, true, url)
            return nil
        }

        let operation = SDWebImageCombinedOperation()

        // Check if URL previously failed
        failedURLsLock.lock()
        let isFailedUrl = failedURLs.contains(url)
        failedURLsLock.unlock()

        if isFailedUrl && !options.contains(.retryFailed) {
            completedBlock?(nil, nil, NSError(domain: SDWebImageErrorDomain, code: -3, userInfo: [NSLocalizedDescriptionKey: "URL is blacklisted"]), .none, true, url)
            return operation
        }

        runningOperationsLock.lock()
        runningOperations.append(operation)
        runningOperationsLock.unlock()

        let key = cacheKey(for: url)

        // Check cache
        operation.cacheOperation = imageCache.queryCacheOperation(forKey: key) { [weak self, weak operation] (image, data, cacheType) in
            guard let self = self, let operation = operation, !operation.cancelled else { return }

            if image != nil && !options.contains(.refreshCached) {
                // Image found in cache
                self.safelyRemoveOperation(operation)
                completedBlock?(image, data, nil, cacheType, true, url)
            } else {
                // Download image
                let shouldDownload = self.delegate?.imageManager(self, shouldDownloadImageFor: url) ?? true

                if shouldDownload {
                    // Progressive download or refresh cached
                    if image != nil && options.contains(.refreshCached) {
                        completedBlock?(image, data, nil, cacheType, true, url)
                    }

                    // Convert options
                    var downloadOptions: SDWebImageDownloaderOptions = []
                    if options.contains(.lowPriority) { downloadOptions.insert(.lowPriority) }
                    if options.contains(.progressiveDownload) { downloadOptions.insert(.progressiveDownload) }
                    if options.contains(.refreshCached) { downloadOptions.insert(.useNSURLCache) }
                    if options.contains(.continueInBackground) { downloadOptions.insert(.continueInBackground) }
                    if options.contains(.handleCookies) { downloadOptions.insert(.handleCookies) }
                    if options.contains(.allowInvalidSSLCertificates) { downloadOptions.insert(.allowInvalidSSLCertificates) }
                    if options.contains(.highPriority) { downloadOptions.insert(.highPriority) }
                    if options.contains(.scaleDownLargeImages) { downloadOptions.insert(.scaleDownLargeImages) }

                    operation.downloadToken = self.imageDownloader.downloadImage(
                        with: url,
                        options: downloadOptions,
                        progress: progressBlock,
                        completed: { [weak self, weak operation] (downloadedImage, downloadedData, error, finished) in
                            guard let self = self, let operation = operation else { return }

                            if error != nil {
                                self.failedURLsLock.lock()
                                self.failedURLs.insert(url)
                                self.failedURLsLock.unlock()

                                completedBlock?(nil, nil, error, .none, finished, url)
                            } else {
                                var transformedImage = downloadedImage

                                // Transform image if delegate method is implemented
                                transformedImage = self.delegate?.imageManager(self, transformDownloadedImage: transformedImage, with: url) ?? transformedImage

                                // Cache the image
                                if let transformedImage = transformedImage, finished {
                                    let shouldCache = !options.contains(.cacheMemoryOnly)
                                    self.imageCache.storeImage(
                                        transformedImage,
                                        imageData: downloadedData,
                                        forKey: key,
                                        toDisk: shouldCache,
                                        completion: nil
                                    )
                                }

                                if !options.contains(.avoidAutoSetImage) {
                                    completedBlock?(transformedImage, downloadedData, nil, .none, finished, url)
                                }
                            }

                            if finished {
                                self.safelyRemoveOperation(operation)
                            }
                        }
                    )
                } else {
                    self.safelyRemoveOperation(operation)
                    completedBlock?(image, data, nil, cacheType, true, url)
                }
            }
        }

        return operation
    }

    // MARK: - Cache Operations

    public func saveImageToCache(_ image: UIImage?, for url: URL?) {
        guard let image = image, let url = url else { return }
        let key = cacheKey(for: url)
        imageCache.storeImage(image, forKey: key, toDisk: true, completion: nil)
    }

    public func cachedImageExists(for url: URL?, completion: SDWebImageCheckCacheCompletionBlock?) {
        guard let url = url else {
            completion?(false)
            return
        }

        let key = cacheKey(for: url)

        if imageCache.imageFromMemoryCache(forKey: key) != nil {
            completion?(true)
            return
        }

        imageCache.diskImageExists(withKey: key, completion: completion)
    }

    public func diskImageExists(for url: URL?, completion: SDWebImageCheckCacheCompletionBlock?) {
        guard let url = url else {
            completion?(false)
            return
        }

        let key = cacheKey(for: url)
        imageCache.diskImageExists(withKey: key, completion: completion)
    }

    public func cacheKey(for url: URL?) -> String? {
        guard let url = url else { return nil }

        if let filter = cacheKeyFilter {
            return filter(url)
        }

        return url.absoluteString
    }

    // MARK: - Control Operations

    public func cancelAll() {
        runningOperationsLock.lock()
        let operations = runningOperations
        runningOperationsLock.unlock()

        for operation in operations {
            operation.cancel()
        }
    }

    public func isRunning() -> Bool {
        runningOperationsLock.lock()
        let count = runningOperations.count
        runningOperationsLock.unlock()
        return count > 0
    }

    // MARK: - Private Methods

    private func safelyRemoveOperation(_ operation: SDWebImageCombinedOperation) {
        runningOperationsLock.lock()
        if let index = runningOperations.firstIndex(of: operation) {
            runningOperations.remove(at: index)
        }
        runningOperationsLock.unlock()
    }
}
