/*
 * This file is part of the SDWebImage package.
 * Swift/SwiftUI version
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import Foundation
import UIKit

// MARK: - Prefetcher Delegate Protocol

public protocol SDWebImagePrefetcherDelegate: AnyObject {
    /// Called when an image was prefetched
    func imagePrefetcher(_ imagePrefetcher: SDWebImagePrefetcher, didPrefetchURL imageURL: URL?)

    /// Called when all images are prefetched
    func imagePrefetcher(_ imagePrefetcher: SDWebImagePrefetcher, didFinishWithTotalCount totalCount: Int, skippedCount: Int)
}

// Make delegate methods optional
public extension SDWebImagePrefetcherDelegate {
    func imagePrefetcher(_ imagePrefetcher: SDWebImagePrefetcher, didPrefetchURL imageURL: URL?) {}
    func imagePrefetcher(_ imagePrefetcher: SDWebImagePrefetcher, didFinishWithTotalCount totalCount: Int, skippedCount: Int) {}
}

// MARK: - Prefetcher Progress Block

public typealias SDWebImagePrefetcherProgressBlock = (_ finishedCount: Int, _ totalCount: Int) -> Void
public typealias SDWebImagePrefetcherCompletionBlock = (_ finishedCount: Int, _ skippedCount: Int) -> Void

// MARK: - Prefetcher

/// SDWebImagePrefetcher is used to prefetch images in the background
public class SDWebImagePrefetcher: NSObject {

    // MARK: - Properties

    /// The web image manager
    public let manager: SDWebImageManager

    /// Maximum number of URLs to prefetch at the same time. Defaults to 3
    public var maxConcurrentDownloads: Int = 3

    /// SDWebImageOptions for prefetcher. Defaults to lowPriority
    public var options: SDWebImageOptions = .lowPriority

    /// Queue options for prefetcher
    public var prefetcherQueue: DispatchQueue = DispatchQueue.main

    /// Delegate
    public weak var delegate: SDWebImagePrefetcherDelegate?

    // MARK: - Private Properties

    private var prefetchURLs = [URL]()
    private var completedBlock: SDWebImagePrefetcherCompletionBlock?
    private var progressBlock: SDWebImagePrefetcherProgressBlock?
    private var finishedCount = 0
    private var skippedCount = 0
    private var totalCount = 0
    private var operations = [SDWebImageOperation]()

    // MARK: - Singleton

    public static let shared = SDWebImagePrefetcher()

    // MARK: - Initialization

    public convenience override init() {
        self.init(imageManager: SDWebImageManager.shared)
    }

    public init(imageManager: SDWebImageManager) {
        self.manager = imageManager
        super.init()
    }

    // MARK: - Prefetch

    /// Prefetch images from an array of URLs
    /// - Parameters:
    ///   - urls: Array of URLs to prefetch
    ///   - progressBlock: Block called when each image completes prefetching
    ///   - completionBlock: Block called when all images complete prefetching
    public func prefetchURLs(
        _ urls: [URL]?,
        progress progressBlock: SDWebImagePrefetcherProgressBlock? = nil,
        completed completionBlock: SDWebImagePrefetcherCompletionBlock? = nil
    ) {
        guard let urls = urls, !urls.isEmpty else {
            completionBlock?(0, 0)
            return
        }

        cancelPrefetching()

        self.completedBlock = completionBlock
        self.progressBlock = progressBlock
        self.prefetchURLs = urls
        self.finishedCount = 0
        self.skippedCount = 0
        self.totalCount = urls.count

        startPrefetching()
    }

    // MARK: - Cancel

    /// Cancel all prefetching operations
    public func cancelPrefetching() {
        for operation in operations {
            operation.cancel()
        }
        operations.removeAll()
        prefetchURLs.removeAll()
        finishedCount = 0
        skippedCount = 0
        totalCount = 0
    }

    // MARK: - Private Methods

    private func startPrefetching() {
        let urlsToFetch = min(maxConcurrentDownloads, prefetchURLs.count)

        for _ in 0..<urlsToFetch {
            if !prefetchURLs.isEmpty {
                prefetchNextURL()
            }
        }
    }

    private func prefetchNextURL() {
        guard !prefetchURLs.isEmpty else {
            reportStatus()
            return
        }

        let url = prefetchURLs.removeFirst()

        let operation = manager.loadImage(
            with: url,
            options: options,
            progress: nil,
            completed: { [weak self] (image, data, error, cacheType, finished, imageURL) in
                guard let self = self else { return }

                if !finished {
                    return
                }

                self.finishedCount += 1

                if image == nil {
                    self.skippedCount += 1
                }

                self.delegate?.imagePrefetcher(self, didPrefetchURL: imageURL)

                self.progressBlock?(self.finishedCount, self.totalCount)

                // Remove completed operation
                if let index = self.operations.firstIndex(where: { $0 === operation }) {
                    self.operations.remove(at: index)
                }

                // Prefetch next URL
                if !self.prefetchURLs.isEmpty {
                    self.prefetchNextURL()
                } else if self.operations.isEmpty {
                    self.reportStatus()
                }
            }
        )

        if let operation = operation {
            operations.append(operation)
        }
    }

    private func reportStatus() {
        completedBlock?(finishedCount, skippedCount)
        delegate?.imagePrefetcher(self, didFinishWithTotalCount: totalCount, skippedCount: skippedCount)
    }
}
