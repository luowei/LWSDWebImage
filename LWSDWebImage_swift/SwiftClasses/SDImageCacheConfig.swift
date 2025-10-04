/*
 * This file is part of the SDWebImage package.
 * Swift/SwiftUI version
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import Foundation

public class SDImageCacheConfig: NSObject {

    /// Decompressing images that are downloaded and cached can improve performance but can consume lot of memory.
    /// Defaults to true. Set this to false if you are experiencing a crash due to excessive memory consumption.
    public var shouldDecompressImages: Bool = true

    /// Disable iCloud backup. Defaults to true
    public var shouldDisableiCloud: Bool = true

    /// Use memory cache. Defaults to true
    public var shouldCacheImagesInMemory: Bool = true

    /// The maximum length of time to keep an image in the cache, in seconds
    /// Default is 1 week (60 * 60 * 24 * 7)
    public var maxCacheAge: Int = 60 * 60 * 24 * 7

    /// The maximum size of the cache, in bytes
    /// Default is 0 (no limit)
    public var maxCacheSize: UInt = 0

    public override init() {
        super.init()
    }
}
