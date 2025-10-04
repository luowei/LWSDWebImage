/*
 * This file is part of the SDWebImage package.
 * Swift/SwiftUI version
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import Foundation
import UIKit

// MARK: - Notifications

public let SDWebImageDownloadStartNotification = "SDWebImageDownloadStartNotification"
public let SDWebImageDownloadStopNotification = "SDWebImageDownloadStopNotification"

// MARK: - Download Token

public class SDWebImageDownloadToken: NSObject {
    public var url: URL?
    public var downloadOperationCancelToken: Any?

    public override init() {
        super.init()
    }
}

// MARK: - Download Operation

private class SDWebImageDownloaderOperation: Operation, SDWebImageOperation {
    var url: URL?
    var options: SDWebImageDownloaderOptions
    var progressBlock: SDWebImageDownloaderProgressBlock?
    var completedBlock: SDWebImageDownloaderCompletedBlock?

    private var task: URLSessionDataTask?
    private var imageData = Data()
    private var expectedSize: Int = 0

    override var isExecuting: Bool {
        return task?.state == .running
    }

    override var isFinished: Bool {
        return task?.state == .completed
    }

    init(url: URL?, options: SDWebImageDownloaderOptions, progress: SDWebImageDownloaderProgressBlock?, completed: SDWebImageDownloaderCompletedBlock?) {
        self.url = url
        self.options = options
        self.progressBlock = progress
        self.completedBlock = completed
        super.init()
    }

    override func main() {
        guard let url = url else {
            completedBlock?(nil, nil, NSError(domain: SDWebImageErrorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]), true)
            return
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 15.0
        request.httpShouldHandleCookies = options.contains(.handleCookies)
        request.httpShouldUsePipelining = true

        let session = URLSession.shared
        task = session.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }

            if let error = error {
                self.completedBlock?(nil, nil, error, true)
                return
            }

            guard let data = data else {
                self.completedBlock?(nil, nil, NSError(domain: SDWebImageErrorDomain, code: -2, userInfo: [NSLocalizedDescriptionKey: "No data"]), true)
                return
            }

            let image = UIImage(data: data)
            self.completedBlock?(image, data, nil, true)
        }

        task?.resume()

        NotificationCenter.default.post(name: NSNotification.Name(SDWebImageDownloadStartNotification), object: self)
    }

    override func cancel() {
        super.cancel()
        task?.cancel()
        NotificationCenter.default.post(name: NSNotification.Name(SDWebImageDownloadStopNotification), object: self)
    }
}

// MARK: - Downloader

public class SDWebImageDownloader: NSObject {

    // MARK: - Properties

    /// Decompressing images that are downloaded and cached can improve performance but can consume lot of memory
    public var shouldDecompressImages: Bool = true

    /// The maximum number of concurrent downloads
    public var maxConcurrentDownloads: Int = 6 {
        didSet {
            downloadQueue.maxConcurrentOperationCount = maxConcurrentDownloads
        }
    }

    /// The current amount of downloads that still need to be downloaded
    public var currentDownloadCount: UInt {
        return UInt(downloadQueue.operationCount)
    }

    /// The timeout value (in seconds) for the download operation
    public var downloadTimeout: TimeInterval = 15.0

    /// Changes download operations execution order
    public var executionOrder: SDWebImageDownloaderExecutionOrder = .fifo {
        didSet {
            downloadQueue.qualityOfService = executionOrder == .lifo ? .userInitiated : .default
        }
    }

    /// Default URL credential
    public var urlCredential: URLCredential?

    /// Username
    public var username: String?

    /// Password
    public var password: String?

    /// Headers filter block
    public var headersFilter: SDWebImageDownloaderHeadersFilterBlock?

    // MARK: - Private Properties

    private let downloadQueue: OperationQueue
    private var headerValues = [String: String]()
    private let barrierQueue = DispatchQueue(label: "com.sdwebimage.SDWebImageDownloaderBarrierQueue", attributes: .concurrent)

    // MARK: - Singleton

    public static let shared = SDWebImageDownloader()

    // MARK: - Initialization

    public override init() {
        downloadQueue = OperationQueue()
        downloadQueue.maxConcurrentOperationCount = 6
        downloadQueue.name = "com.sdwebimage.SDWebImageDownloader"
        super.init()
    }

    public init(sessionConfiguration: URLSessionConfiguration?) {
        downloadQueue = OperationQueue()
        downloadQueue.maxConcurrentOperationCount = 6
        downloadQueue.name = "com.sdwebimage.SDWebImageDownloader"
        super.init()
    }

    // MARK: - Header Management

    public func setValue(_ value: String?, forHTTPHeaderField field: String?) {
        guard let field = field else { return }

        barrierQueue.async(flags: .barrier) { [weak self] in
            if let value = value {
                self?.headerValues[field] = value
            } else {
                self?.headerValues.removeValue(forKey: field)
            }
        }
    }

    public func value(forHTTPHeaderField field: String?) -> String? {
        guard let field = field else { return nil }

        var value: String?
        barrierQueue.sync {
            value = headerValues[field]
        }
        return value
    }

    // MARK: - Download Operations

    @discardableResult
    public func downloadImage(
        with url: URL?,
        options: SDWebImageDownloaderOptions = [],
        progress progressBlock: SDWebImageDownloaderProgressBlock? = nil,
        completed completedBlock: SDWebImageDownloaderCompletedBlock? = nil
    ) -> SDWebImageDownloadToken? {
        guard let url = url else {
            completedBlock?(nil, nil, NSError(domain: SDWebImageErrorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]), true)
            return nil
        }

        let operation = SDWebImageDownloaderOperation(
            url: url,
            options: options,
            progress: progressBlock,
            completed: completedBlock
        )

        if options.contains(.highPriority) {
            operation.queuePriority = .high
        } else if options.contains(.lowPriority) {
            operation.queuePriority = .low
        } else {
            operation.queuePriority = .normal
        }

        downloadQueue.addOperation(operation)

        let token = SDWebImageDownloadToken()
        token.url = url
        token.downloadOperationCancelToken = operation

        return token
    }

    public func cancel(_ token: SDWebImageDownloadToken?) {
        guard let operation = token?.downloadOperationCancelToken as? Operation else { return }
        operation.cancel()
    }

    public func setSuspended(_ suspended: Bool) {
        downloadQueue.isSuspended = suspended
    }

    public func cancelAllDownloads() {
        downloadQueue.cancelAllOperations()
    }
}
