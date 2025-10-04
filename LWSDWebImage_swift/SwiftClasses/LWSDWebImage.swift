/*
 * This file is part of the SDWebImage package.
 * Swift/SwiftUI version
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import Foundation
import UIKit

/// LWSDWebImage - Swift/SwiftUI version
///
/// A modern Swift implementation of the SDWebImage library with full SwiftUI support.
///
/// Features:
/// - Asynchronous image downloading and caching
/// - Memory and disk caching
/// - SwiftUI support with modern view modifiers
/// - UIKit extensions for UIImageView and UIButton
/// - GIF support
/// - Image prefetching
/// - Customizable options and delegates
///
/// Usage:
///
/// SwiftUI:
/// ```swift
/// import LWSDWebImage
///
/// WebImage(url: URL(string: "https://example.com/image.jpg"))
///     .resizable()
///     .aspectRatio(contentMode: .fit)
///
/// // Or using SDAsyncImage (iOS 15+)
/// SDAsyncImage(url: URL(string: "https://example.com/image.jpg")) { image in
///     Image(uiImage: image)
///         .resizable()
/// } placeholder: {
///     ProgressView()
/// }
/// ```
///
/// UIKit:
/// ```swift
/// import LWSDWebImage
///
/// imageView.sd_setImage(with: URL(string: "https://example.com/image.jpg"),
///                      placeholderImage: UIImage(named: "placeholder"))
///
/// button.sd_setImage(with: URL(string: "https://example.com/image.jpg"),
///                   for: .normal,
///                   placeholderImage: UIImage(named: "placeholder"))
/// ```
///
/// Manager:
/// ```swift
/// SDWebImageManager.shared.loadImage(
///     with: URL(string: "https://example.com/image.jpg"),
///     options: [.retryFailed, .highPriority],
///     progress: { receivedSize, expectedSize, targetURL in
///         print("Progress: \(receivedSize)/\(expectedSize)")
///     },
///     completed: { image, data, error, cacheType, finished, url in
///         if let image = image {
///             print("Image loaded successfully")
///         }
///     }
/// )
/// ```
///
/// Cache:
/// ```swift
/// // Store image
/// SDImageCache.shared.storeImage(image, forKey: "myKey")
///
/// // Query cache
/// SDImageCache.shared.queryCacheOperation(forKey: "myKey") { image, data, cacheType in
///     if let image = image {
///         print("Image found in cache: \(cacheType)")
///     }
/// }
///
/// // Clear cache
/// SDImageCache.shared.clearMemory()
/// SDImageCache.shared.clearDisk()
/// ```
///
/// Prefetcher:
/// ```swift
/// let urls = [
///     URL(string: "https://example.com/image1.jpg")!,
///     URL(string: "https://example.com/image2.jpg")!
/// ]
///
/// SDWebImagePrefetcher.shared.prefetchURLs(
///     urls,
///     progress: { finishedCount, totalCount in
///         print("Prefetched \(finishedCount)/\(totalCount)")
///     },
///     completed: { finishedCount, skippedCount in
///         print("Prefetching completed")
///     }
/// )
/// ```

public struct LWSDWebImage {
    public static let version = "1.0.0"
    public static let name = "LWSDWebImage"

    /// Get the shared image manager
    public static var sharedManager: SDWebImageManager {
        return SDWebImageManager.shared
    }

    /// Get the shared image cache
    public static var sharedCache: SDImageCache {
        return SDImageCache.shared
    }

    /// Get the shared image downloader
    public static var sharedDownloader: SDWebImageDownloader {
        return SDWebImageDownloader.shared
    }

    /// Get the shared image prefetcher
    public static var sharedPrefetcher: SDWebImagePrefetcher {
        return SDWebImagePrefetcher.shared
    }
}
