/*
 * This file is part of the SDWebImage package.
 * Swift/SwiftUI version
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import UIKit

// MARK: - UIButton Extension for Web Caching

private var imageURLStorageKey: Void?
private var backgroundImageURLStorageKey: Void?
private var imageOperationStorageKey: Void?
private var backgroundImageOperationStorageKey: Void?

public extension UIButton {

    // MARK: - Storage

    private var sd_imageURLStorage: [UInt: URL] {
        get {
            return objc_getAssociatedObject(self, &imageURLStorageKey) as? [UInt: URL] ?? [:]
        }
        set {
            objc_setAssociatedObject(self, &imageURLStorageKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    private var sd_backgroundImageURLStorage: [UInt: URL] {
        get {
            return objc_getAssociatedObject(self, &backgroundImageURLStorageKey) as? [UInt: URL] ?? [:]
        }
        set {
            objc_setAssociatedObject(self, &backgroundImageURLStorageKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    private var sd_imageOperationStorage: [UInt: SDWebImageOperation] {
        get {
            return objc_getAssociatedObject(self, &imageOperationStorageKey) as? [UInt: SDWebImageOperation] ?? [:]
        }
        set {
            objc_setAssociatedObject(self, &imageOperationStorageKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    private var sd_backgroundImageOperationStorage: [UInt: SDWebImageOperation] {
        get {
            return objc_getAssociatedObject(self, &backgroundImageOperationStorageKey) as? [UInt: SDWebImageOperation] ?? [:]
        }
        set {
            objc_setAssociatedObject(self, &backgroundImageOperationStorageKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    // MARK: - Current URL

    func sd_currentImageURL() -> URL? {
        return sd_imageURL(for: state)
    }

    func sd_imageURL(for state: UIControl.State) -> URL? {
        return sd_imageURLStorage[state.rawValue]
    }

    // MARK: - Image Loading

    func sd_setImage(with url: URL?, for state: UIControl.State) {
        sd_setImage(with: url, for: state, placeholderImage: nil, options: [], completed: nil)
    }

    func sd_setImage(with url: URL?, for state: UIControl.State, placeholderImage placeholder: UIImage?) {
        sd_setImage(with: url, for: state, placeholderImage: placeholder, options: [], completed: nil)
    }

    func sd_setImage(with url: URL?, for state: UIControl.State, placeholderImage placeholder: UIImage?, options: SDWebImageOptions) {
        sd_setImage(with: url, for: state, placeholderImage: placeholder, options: options, completed: nil)
    }

    func sd_setImage(with url: URL?, for state: UIControl.State, completed completedBlock: SDExternalCompletionBlock?) {
        sd_setImage(with: url, for: state, placeholderImage: nil, options: [], completed: completedBlock)
    }

    func sd_setImage(with url: URL?, for state: UIControl.State, placeholderImage placeholder: UIImage?, completed completedBlock: SDExternalCompletionBlock?) {
        sd_setImage(with: url, for: state, placeholderImage: placeholder, options: [], completed: completedBlock)
    }

    func sd_setImage(
        with url: URL?,
        for state: UIControl.State,
        placeholderImage placeholder: UIImage?,
        options: SDWebImageOptions,
        completed completedBlock: SDExternalCompletionBlock?
    ) {
        sd_cancelImageLoad(for: state)

        if let url = url {
            sd_imageURLStorage[state.rawValue] = url
        } else {
            sd_imageURLStorage.removeValue(forKey: state.rawValue)
        }

        if let placeholder = placeholder {
            setImage(placeholder, for: state)
        }

        guard let url = url else {
            completedBlock?(nil, NSError(domain: SDWebImageErrorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey: "URL is nil"]), .none, nil)
            return
        }

        let operation = SDWebImageManager.shared.loadImage(
            with: url,
            options: options,
            progress: nil,
            completed: { [weak self] (image, data, error, cacheType, finished, imageURL) in
                guard let self = self else { return }

                if !finished { return }

                if let image = image, !options.contains(.avoidAutoSetImage) {
                    self.setImage(image, for: state)
                }

                completedBlock?(image, error, cacheType, imageURL)
            }
        )

        if let operation = operation {
            sd_imageOperationStorage[state.rawValue] = operation
        }
    }

    // MARK: - Background Image Loading

    func sd_setBackgroundImage(with url: URL?, for state: UIControl.State) {
        sd_setBackgroundImage(with: url, for: state, placeholderImage: nil, options: [], completed: nil)
    }

    func sd_setBackgroundImage(with url: URL?, for state: UIControl.State, placeholderImage placeholder: UIImage?) {
        sd_setBackgroundImage(with: url, for: state, placeholderImage: placeholder, options: [], completed: nil)
    }

    func sd_setBackgroundImage(with url: URL?, for state: UIControl.State, placeholderImage placeholder: UIImage?, options: SDWebImageOptions) {
        sd_setBackgroundImage(with: url, for: state, placeholderImage: placeholder, options: options, completed: nil)
    }

    func sd_setBackgroundImage(with url: URL?, for state: UIControl.State, completed completedBlock: SDExternalCompletionBlock?) {
        sd_setBackgroundImage(with: url, for: state, placeholderImage: nil, options: [], completed: completedBlock)
    }

    func sd_setBackgroundImage(with url: URL?, for state: UIControl.State, placeholderImage placeholder: UIImage?, completed completedBlock: SDExternalCompletionBlock?) {
        sd_setBackgroundImage(with: url, for: state, placeholderImage: placeholder, options: [], completed: completedBlock)
    }

    func sd_setBackgroundImage(
        with url: URL?,
        for state: UIControl.State,
        placeholderImage placeholder: UIImage?,
        options: SDWebImageOptions,
        completed completedBlock: SDExternalCompletionBlock?
    ) {
        sd_cancelBackgroundImageLoad(for: state)

        if let url = url {
            sd_backgroundImageURLStorage[state.rawValue] = url
        } else {
            sd_backgroundImageURLStorage.removeValue(forKey: state.rawValue)
        }

        if let placeholder = placeholder {
            setBackgroundImage(placeholder, for: state)
        }

        guard let url = url else {
            completedBlock?(nil, NSError(domain: SDWebImageErrorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey: "URL is nil"]), .none, nil)
            return
        }

        let operation = SDWebImageManager.shared.loadImage(
            with: url,
            options: options,
            progress: nil,
            completed: { [weak self] (image, data, error, cacheType, finished, imageURL) in
                guard let self = self else { return }

                if !finished { return }

                if let image = image, !options.contains(.avoidAutoSetImage) {
                    self.setBackgroundImage(image, for: state)
                }

                completedBlock?(image, error, cacheType, imageURL)
            }
        )

        if let operation = operation {
            sd_backgroundImageOperationStorage[state.rawValue] = operation
        }
    }

    // MARK: - Cancel

    func sd_cancelImageLoad(for state: UIControl.State) {
        if let operation = sd_imageOperationStorage[state.rawValue] {
            operation.cancel()
            sd_imageOperationStorage.removeValue(forKey: state.rawValue)
        }
    }

    func sd_cancelBackgroundImageLoad(for state: UIControl.State) {
        if let operation = sd_backgroundImageOperationStorage[state.rawValue] {
            operation.cancel()
            sd_backgroundImageOperationStorage.removeValue(forKey: state.rawValue)
        }
    }
}
