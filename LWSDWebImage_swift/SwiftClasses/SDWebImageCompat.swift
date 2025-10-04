/*
 * This file is part of the SDWebImage package.
 * Swift/SwiftUI version
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import Foundation
import UIKit

// MARK: - Type Aliases

public typealias SDWebImageNoParamsBlock = () -> Void

// MARK: - Error Domain

public let SDWebImageErrorDomain = "SDWebImageErrorDomain"

// MARK: - Enums

public enum SDImageCacheType: Int {
    /// The image wasn't available in SDWebImage caches, but was downloaded from the web
    case none
    /// The image was obtained from the disk cache
    case disk
    /// The image was obtained from the memory cache
    case memory
}

public struct SDWebImageOptions: OptionSet {
    public let rawValue: UInt

    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }

    /// By default, when a URL fails to be downloaded, the URL is blacklisted.
    /// This flag disables this blacklisting.
    public static let retryFailed = SDWebImageOptions(rawValue: 1 << 0)

    /// By default, image downloads are started during UI interactions.
    /// This flag disables this feature, leading to delayed download on UIScrollView deceleration.
    public static let lowPriority = SDWebImageOptions(rawValue: 1 << 1)

    /// This flag disables on-disk caching
    public static let cacheMemoryOnly = SDWebImageOptions(rawValue: 1 << 2)

    /// This flag enables progressive download, the image is displayed progressively during download
    public static let progressiveDownload = SDWebImageOptions(rawValue: 1 << 3)

    /// Even if the image is cached, respect the HTTP response cache control
    public static let refreshCached = SDWebImageOptions(rawValue: 1 << 4)

    /// In iOS 4+, continue the download of the image if the app goes to background
    public static let continueInBackground = SDWebImageOptions(rawValue: 1 << 5)

    /// Handles cookies stored in NSHTTPCookieStore
    public static let handleCookies = SDWebImageOptions(rawValue: 1 << 6)

    /// Enable to allow untrusted SSL certificates
    public static let allowInvalidSSLCertificates = SDWebImageOptions(rawValue: 1 << 7)

    /// By default, images are loaded in the order they were queued.
    /// This flag moves them to the front of the queue.
    public static let highPriority = SDWebImageOptions(rawValue: 1 << 8)

    /// Delay the loading of the placeholder image until after the image has finished loading
    public static let delayPlaceholder = SDWebImageOptions(rawValue: 1 << 9)

    /// Transform animated images
    public static let transformAnimatedImage = SDWebImageOptions(rawValue: 1 << 10)

    /// Manually set the image in the completion when success
    public static let avoidAutoSetImage = SDWebImageOptions(rawValue: 1 << 11)

    /// Scale down large images
    public static let scaleDownLargeImages = SDWebImageOptions(rawValue: 1 << 12)
}

public struct SDWebImageDownloaderOptions: OptionSet {
    public let rawValue: UInt

    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }

    public static let lowPriority = SDWebImageDownloaderOptions(rawValue: 1 << 0)
    public static let progressiveDownload = SDWebImageDownloaderOptions(rawValue: 1 << 1)
    public static let useNSURLCache = SDWebImageDownloaderOptions(rawValue: 1 << 2)
    public static let ignoreCachedResponse = SDWebImageDownloaderOptions(rawValue: 1 << 3)
    public static let continueInBackground = SDWebImageDownloaderOptions(rawValue: 1 << 4)
    public static let handleCookies = SDWebImageDownloaderOptions(rawValue: 1 << 5)
    public static let allowInvalidSSLCertificates = SDWebImageDownloaderOptions(rawValue: 1 << 6)
    public static let highPriority = SDWebImageDownloaderOptions(rawValue: 1 << 7)
    public static let scaleDownLargeImages = SDWebImageDownloaderOptions(rawValue: 1 << 8)
}

public enum SDWebImageDownloaderExecutionOrder: Int {
    /// All download operations execute in queue style (first-in-first-out)
    case fifo
    /// All download operations execute in stack style (last-in-first-out)
    case lifo
}

// MARK: - Completion Blocks

public typealias SDExternalCompletionBlock = (_ image: UIImage?, _ error: Error?, _ cacheType: SDImageCacheType, _ imageURL: URL?) -> Void

public typealias SDInternalCompletionBlock = (_ image: UIImage?, _ data: Data?, _ error: Error?, _ cacheType: SDImageCacheType, _ finished: Bool, _ imageURL: URL?) -> Void

public typealias SDWebImageDownloaderProgressBlock = (_ receivedSize: Int, _ expectedSize: Int, _ targetURL: URL?) -> Void

public typealias SDWebImageDownloaderCompletedBlock = (_ image: UIImage?, _ data: Data?, _ error: Error?, _ finished: Bool) -> Void

public typealias SDCacheQueryCompletedBlock = (_ image: UIImage?, _ data: Data?, _ cacheType: SDImageCacheType) -> Void

public typealias SDWebImageCheckCacheCompletionBlock = (_ isInCache: Bool) -> Void

public typealias SDWebImageCalculateSizeBlock = (_ fileCount: UInt, _ totalSize: UInt) -> Void

public typealias SDWebImageCacheKeyFilterBlock = (_ url: URL?) -> String?

public typealias SDWebImageDownloaderHeadersFilterBlock = (_ url: URL?, _ headers: [String: String]?) -> [String: String]?

// MARK: - Protocols

public protocol SDWebImageOperation {
    func cancel()
}

// MARK: - Helper Functions

public func SDScaledImageForKey(_ key: String?, _ image: UIImage?) -> UIImage? {
    guard let image = image else { return nil }
    guard let key = key else { return image }

    if image.images != nil {
        // Animated image
        return image
    }

    if image.scale == UIScreen.main.scale {
        return image
    }

    return UIImage(cgImage: image.cgImage!, scale: UIScreen.main.scale, orientation: image.imageOrientation)
}

// MARK: - Main Thread Safety

public func dispatchMainAsyncSafe(_ block: @escaping () -> Void) {
    if Thread.isMainThread {
        block()
    } else {
        DispatchQueue.main.async(execute: block)
    }
}
