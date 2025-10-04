/*
 * This file is part of the SDWebImage package.
 * Swift/SwiftUI version
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import Foundation
import UIKit

/// SDImageCache maintains a memory cache and an optional disk cache.
/// Disk cache write operations are performed asynchronously.
public class SDImageCache: NSObject {

    // MARK: - Properties

    /// Cache Config object - storing all kind of settings
    public let config: SDImageCacheConfig

    /// The maximum "total cost" of the in-memory image cache
    public var maxMemoryCost: UInt = 0 {
        didSet {
            memoryCache.totalCostLimit = Int(maxMemoryCost)
        }
    }

    /// The maximum number of objects the cache should hold
    public var maxMemoryCountLimit: UInt = 0 {
        didSet {
            memoryCache.countLimit = Int(maxMemoryCountLimit)
        }
    }

    // MARK: - Private Properties

    private let memoryCache = NSCache<NSString, UIImage>()
    private let diskCachePath: String
    private let ioQueue: DispatchQueue
    private let fileManager: FileManager

    // MARK: - Singleton

    public static let shared = SDImageCache(namespace: "default")

    // MARK: - Initialization

    public convenience override init() {
        self.init(namespace: "default")
    }

    public init(namespace: String) {
        self.config = SDImageCacheConfig()
        self.ioQueue = DispatchQueue(label: "com.sdwebimage.SDImageCache", qos: .background)
        self.fileManager = FileManager.default

        let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        let diskCachePath = paths[0] + "/default/" + namespace
        self.diskCachePath = diskCachePath

        super.init()

        // Create cache directories
        try? fileManager.createDirectory(atPath: diskCachePath, withIntermediateDirectories: true, attributes: nil)

        // Subscribe to app events
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(clearMemory),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(deleteOldFiles),
            name: UIApplication.willTerminateNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(backgroundDeleteOldFiles),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
    }

    public init(namespace: String, diskCacheDirectory: String) {
        self.config = SDImageCacheConfig()
        self.ioQueue = DispatchQueue(label: "com.sdwebimage.SDImageCache", qos: .background)
        self.fileManager = FileManager.default
        self.diskCachePath = diskCacheDirectory + "/" + namespace

        super.init()

        try? fileManager.createDirectory(atPath: diskCachePath, withIntermediateDirectories: true, attributes: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Store Operations

    public func storeImage(_ image: UIImage?, forKey key: String?, completion: SDWebImageNoParamsBlock? = nil) {
        storeImage(image, forKey: key, toDisk: true, completion: completion)
    }

    public func storeImage(_ image: UIImage?, forKey key: String?, toDisk: Bool, completion: SDWebImageNoParamsBlock? = nil) {
        storeImage(image, imageData: nil, forKey: key, toDisk: toDisk, completion: completion)
    }

    public func storeImage(_ image: UIImage?, imageData: Data?, forKey key: String?, toDisk: Bool, completion: SDWebImageNoParamsBlock? = nil) {
        guard let image = image, let key = key else {
            completion?()
            return
        }

        // Store in memory cache
        if config.shouldCacheImagesInMemory {
            let cost = image.size.width * image.size.height * image.scale * image.scale
            memoryCache.setObject(image, forKey: key as NSString, cost: Int(cost))
        }

        if toDisk {
            ioQueue.async { [weak self] in
                guard let self = self else { return }

                var data = imageData
                if data == nil {
                    if let pngData = image.pngData() {
                        data = pngData
                    }
                }

                if let data = data {
                    self.storeImageDataToDisk(data, forKey: key)
                }

                if let completion = completion {
                    DispatchQueue.main.async {
                        completion()
                    }
                }
            }
        } else {
            completion?()
        }
    }

    public func storeImageDataToDisk(_ imageData: Data?, forKey key: String?) {
        guard let imageData = imageData, let key = key else { return }

        if !fileManager.fileExists(atPath: diskCachePath) {
            try? fileManager.createDirectory(atPath: diskCachePath, withIntermediateDirectories: true, attributes: nil)
        }

        let cachePathForKey = defaultCachePath(forKey: key)
        let url = URL(fileURLWithPath: cachePathForKey)

        try? imageData.write(to: url, options: .atomic)

        if config.shouldDisableiCloud {
            var resourceValues = URLResourceValues()
            resourceValues.isExcludedFromBackup = true
            try? (url as NSURL).setResourceValues(resourceValues)
        }
    }

    // MARK: - Query Operations

    public func diskImageExists(withKey key: String?, completion: SDWebImageCheckCacheCompletionBlock?) {
        ioQueue.async { [weak self] in
            guard let self = self, let key = key else {
                DispatchQueue.main.async {
                    completion?(false)
                }
                return
            }

            let exists = self.fileManager.fileExists(atPath: self.defaultCachePath(forKey: key))
            DispatchQueue.main.async {
                completion?(exists)
            }
        }
    }

    @discardableResult
    public func queryCacheOperation(forKey key: String?, done doneBlock: SDCacheQueryCompletedBlock?) -> Operation? {
        guard let key = key else {
            doneBlock?(nil, nil, .none)
            return nil
        }

        // Check memory cache
        if let image = imageFromMemoryCache(forKey: key) {
            let imageData = diskImageData(forKey: key)
            doneBlock?(image, imageData, .memory)
            return nil
        }

        let operation = BlockOperation()
        operation.addExecutionBlock { [weak self, weak operation] in
            guard let self = self, let operation = operation, !operation.isCancelled else { return }

            let diskData = self.diskImageData(forKey: key)
            var diskImage: UIImage?

            if let diskData = diskData {
                diskImage = UIImage(data: diskData)
                diskImage = self.scaledImage(forKey: key, image: diskImage)

                if self.config.shouldCacheImagesInMemory, let diskImage = diskImage {
                    let cost = diskImage.size.width * diskImage.size.height * diskImage.scale * diskImage.scale
                    self.memoryCache.setObject(diskImage, forKey: key as NSString, cost: Int(cost))
                }
            }

            if !operation.isCancelled {
                DispatchQueue.main.async {
                    doneBlock?(diskImage, diskData, diskImage != nil ? .disk : .none)
                }
            }
        }

        ioQueue.async {
            operation.start()
        }

        return operation
    }

    public func imageFromMemoryCache(forKey key: String?) -> UIImage? {
        guard let key = key else { return nil }
        return memoryCache.object(forKey: key as NSString)
    }

    public func imageFromDiskCache(forKey key: String?) -> UIImage? {
        guard let data = diskImageData(forKey: key) else { return nil }
        let image = UIImage(data: data)
        return scaledImage(forKey: key, image: image)
    }

    public func imageFromCache(forKey key: String?) -> UIImage? {
        if let memoryImage = imageFromMemoryCache(forKey: key) {
            return memoryImage
        }
        return imageFromDiskCache(forKey: key)
    }

    public func diskImageData(forKey key: String?) -> Data? {
        guard let key = key else { return nil }
        let filePath = defaultCachePath(forKey: key)
        return try? Data(contentsOf: URL(fileURLWithPath: filePath))
    }

    public func scaledImage(forKey key: String?, image: UIImage?) -> UIImage? {
        return SDScaledImageForKey(key, image)
    }

    // MARK: - Remove Operations

    public func removeImage(forKey key: String?, completion: SDWebImageNoParamsBlock? = nil) {
        removeImage(forKey: key, fromDisk: true, completion: completion)
    }

    public func removeImage(forKey key: String?, fromDisk: Bool, completion: SDWebImageNoParamsBlock? = nil) {
        guard let key = key else {
            completion?()
            return
        }

        if config.shouldCacheImagesInMemory {
            memoryCache.removeObject(forKey: key as NSString)
        }

        if fromDisk {
            ioQueue.async { [weak self] in
                guard let self = self else { return }
                let filePath = self.defaultCachePath(forKey: key)
                try? self.fileManager.removeItem(atPath: filePath)

                DispatchQueue.main.async {
                    completion?()
                }
            }
        } else {
            completion?()
        }
    }

    // MARK: - Cache Clean Operations

    @objc public func clearMemory() {
        memoryCache.removeAllObjects()
    }

    public func clearDisk(completion: SDWebImageNoParamsBlock? = nil) {
        ioQueue.async { [weak self] in
            guard let self = self else { return }
            try? self.fileManager.removeItem(atPath: self.diskCachePath)
            try? self.fileManager.createDirectory(atPath: self.diskCachePath, withIntermediateDirectories: true, attributes: nil)

            DispatchQueue.main.async {
                completion?()
            }
        }
    }

    @objc private func deleteOldFiles() {
        deleteOldFiles(completion: nil)
    }

    @objc private func backgroundDeleteOldFiles() {
        var backgroundTask: UIBackgroundTaskIdentifier = .invalid
        backgroundTask = UIApplication.shared.beginBackgroundTask {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }

        deleteOldFiles {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
    }

    public func deleteOldFiles(completion: SDWebImageNoParamsBlock? = nil) {
        ioQueue.async { [weak self] in
            guard let self = self else { return }

            let diskCacheURL = URL(fileURLWithPath: self.diskCachePath)
            let resourceKeys: [URLResourceKey] = [.isDirectoryKey, .contentModificationDateKey, .totalFileAllocatedSizeKey]

            guard let fileEnumerator = self.fileManager.enumerator(
                at: diskCacheURL,
                includingPropertiesForKeys: resourceKeys,
                options: .skipsHiddenFiles,
                errorHandler: nil
            ) else { return }

            let expirationDate = Date(timeIntervalSinceNow: -TimeInterval(self.config.maxCacheAge))
            var cacheFiles = [URL: URLResourceValues]()
            var urlsToDelete = [URL]()
            var currentCacheSize: UInt = 0

            for case let fileURL as URL in fileEnumerator {
                guard let resourceValues = try? fileURL.resourceValues(forKeys: Set(resourceKeys)) else { continue }
                guard resourceValues.isDirectory != true else { continue }

                if let modificationDate = resourceValues.contentModificationDate,
                   modificationDate < expirationDate {
                    urlsToDelete.append(fileURL)
                } else {
                    if let fileSize = resourceValues.totalFileAllocatedSize {
                        currentCacheSize += UInt(fileSize)
                        cacheFiles[fileURL] = resourceValues
                    }
                }
            }

            for url in urlsToDelete {
                try? self.fileManager.removeItem(at: url)
            }

            // If cache size exceeds max size, remove files by date
            if self.config.maxCacheSize > 0 && currentCacheSize > self.config.maxCacheSize {
                let desiredCacheSize = self.config.maxCacheSize / 2

                let sortedFiles = cacheFiles.sorted {
                    let date1 = $0.value.contentModificationDate ?? Date.distantPast
                    let date2 = $1.value.contentModificationDate ?? Date.distantPast
                    return date1.compare(date2) == .orderedAscending
                }

                for (url, resourceValues) in sortedFiles {
                    try? self.fileManager.removeItem(at: url)
                    if let fileSize = resourceValues.totalFileAllocatedSize {
                        currentCacheSize -= UInt(fileSize)
                    }

                    if currentCacheSize < desiredCacheSize {
                        break
                    }
                }
            }

            DispatchQueue.main.async {
                completion?()
            }
        }
    }

    // MARK: - Cache Info

    public func getSize() -> UInt {
        var size: UInt = 0
        let diskCacheURL = URL(fileURLWithPath: diskCachePath)

        if let fileEnumerator = fileManager.enumerator(at: diskCacheURL, includingPropertiesForKeys: [.totalFileAllocatedSizeKey], options: .skipsHiddenFiles, errorHandler: nil) {
            for case let fileURL as URL in fileEnumerator {
                if let resourceValues = try? fileURL.resourceValues(forKeys: [.totalFileAllocatedSizeKey]),
                   let fileSize = resourceValues.totalFileAllocatedSize {
                    size += UInt(fileSize)
                }
            }
        }

        return size
    }

    public func getDiskCount() -> UInt {
        var count: UInt = 0
        let diskCacheURL = URL(fileURLWithPath: diskCachePath)

        if let fileEnumerator = fileManager.enumerator(at: diskCacheURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles, errorHandler: nil) {
            for _ in fileEnumerator {
                count += 1
            }
        }

        return count
    }

    public func calculateSize(completion: SDWebImageCalculateSizeBlock?) {
        ioQueue.async { [weak self] in
            guard let self = self else { return }

            let fileCount = self.getDiskCount()
            let totalSize = self.getSize()

            DispatchQueue.main.async {
                completion?(fileCount, totalSize)
            }
        }
    }

    // MARK: - Cache Paths

    public func cachePath(forKey key: String?, inPath path: String) -> String? {
        guard let key = key else { return nil }
        let filename = cacheFileName(forKey: key)
        return path + "/" + filename
    }

    public func defaultCachePath(forKey key: String?) -> String {
        guard let key = key else { return "" }
        let filename = cacheFileName(forKey: key)
        return diskCachePath + "/" + filename
    }

    private func cacheFileName(forKey key: String) -> String {
        let key = key as NSString
        let hash = key.hash
        return "\(hash)"
    }
}
