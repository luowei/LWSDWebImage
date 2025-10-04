/*
 * This file is part of the SDWebImage package.
 * Swift/SwiftUI version
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import UIKit

// MARK: - UIImageView Extension for Web Caching

private var imageURLKey: Void?
private var imageOperationKey: Void?

public extension UIImageView {

    // MARK: - Properties

    private var sd_imageURL: URL? {
        get {
            return objc_getAssociatedObject(self, &imageURLKey) as? URL
        }
        set {
            objc_setAssociatedObject(self, &imageURLKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    private var sd_imageOperation: SDWebImageOperation? {
        get {
            return objc_getAssociatedObject(self, &imageOperationKey) as? SDWebImageOperation
        }
        set {
            objc_setAssociatedObject(self, &imageOperationKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    // MARK: - Basic Loading Methods

    func sd_setImage(with url: URL?) {
        sd_setImage(with: url, placeholderImage: nil, options: [], progress: nil, completed: nil)
    }

    func sd_setImage(with url: URL?, placeholderImage placeholder: UIImage?) {
        sd_setImage(with: url, placeholderImage: placeholder, options: [], progress: nil, completed: nil)
    }

    func sd_setImage(with url: URL?, placeholderImage placeholder: UIImage?, options: SDWebImageOptions) {
        sd_setImage(with: url, placeholderImage: placeholder, options: options, progress: nil, completed: nil)
    }

    func sd_setImage(with url: URL?, completed completedBlock: SDExternalCompletionBlock?) {
        sd_setImage(with: url, placeholderImage: nil, options: [], progress: nil, completed: completedBlock)
    }

    func sd_setImage(with url: URL?, placeholderImage placeholder: UIImage?, completed completedBlock: SDExternalCompletionBlock?) {
        sd_setImage(with: url, placeholderImage: placeholder, options: [], progress: nil, completed: completedBlock)
    }

    func sd_setImage(with url: URL?, placeholderImage placeholder: UIImage?, options: SDWebImageOptions, completed completedBlock: SDExternalCompletionBlock?) {
        sd_setImage(with: url, placeholderImage: placeholder, options: options, progress: nil, completed: completedBlock)
    }

    // MARK: - Main Loading Method

    func sd_setImage(
        with url: URL?,
        placeholderImage placeholder: UIImage?,
        options: SDWebImageOptions,
        progress progressBlock: SDWebImageDownloaderProgressBlock?,
        completed completedBlock: SDExternalCompletionBlock?
    ) {
        sd_cancelCurrentImageLoad()

        sd_imageURL = url

        if !options.contains(.delayPlaceholder) {
            DispatchQueue.main.async { [weak self] in
                self?.image = placeholder
            }
        }

        guard let url = url else {
            DispatchQueue.main.async {
                completedBlock?(nil, NSError(domain: SDWebImageErrorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey: "URL is nil"]), .none, nil)
            }
            return
        }

        let operation = SDWebImageManager.shared.loadImage(
            with: url,
            options: options,
            progress: progressBlock,
            completed: { [weak self] (image, data, error, cacheType, finished, imageURL) in
                guard let self = self else { return }

                if !finished {
                    return
                }

                // Check if the image load was cancelled
                if self.sd_imageURL != url {
                    return
                }

                if let image = image {
                    if !options.contains(.avoidAutoSetImage) {
                        self.image = image
                        self.setNeedsLayout()
                    }
                } else if options.contains(.delayPlaceholder) {
                    self.image = placeholder
                    self.setNeedsLayout()
                }

                completedBlock?(image, error, cacheType, imageURL)
            }
        )

        sd_imageOperation = operation
    }

    // MARK: - Previous Cached Image

    func sd_setImageWithPreviousCachedImage(
        with url: URL?,
        placeholderImage placeholder: UIImage?,
        options: SDWebImageOptions,
        progress progressBlock: SDWebImageDownloaderProgressBlock?,
        completed completedBlock: SDExternalCompletionBlock?
    ) {
        let key = SDWebImageManager.shared.cacheKey(for: url)

        if let previousImage = SDImageCache.shared.imageFromMemoryCache(forKey: key) {
            image = previousImage
        } else {
            image = placeholder
        }

        sd_setImage(with: url, placeholderImage: nil, options: options, progress: progressBlock, completed: completedBlock)
    }

    // MARK: - Animation

    func sd_setAnimationImages(with arrayOfURLs: [URL]) {
        sd_cancelCurrentAnimationImagesLoad()

        var operations = [SDWebImageOperation]()
        var images = [UIImage?](repeating: nil, count: arrayOfURLs.count)

        for (index, url) in arrayOfURLs.enumerated() {
            let operation = SDWebImageManager.shared.loadImage(
                with: url,
                options: [],
                progress: nil,
                completed: { [weak self] (image, data, error, cacheType, finished, imageURL) in
                    if !finished { return }

                    images[index] = image

                    // Check if all images are loaded
                    let allLoaded = images.allSatisfy { $0 != nil }
                    if allLoaded {
                        self?.animationImages = images.compactMap { $0 }
                    }
                }
            )

            if let operation = operation {
                operations.append(operation)
            }
        }
    }

    func sd_cancelCurrentAnimationImagesLoad() {
        // Cancel all animation loading operations
        // This would require maintaining a list of operations
    }

    // MARK: - Cancel

    func sd_cancelCurrentImageLoad() {
        sd_imageOperation?.cancel()
        sd_imageOperation = nil
    }
}
