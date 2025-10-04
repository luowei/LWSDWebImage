/*
 * This file is part of the SDWebImage package.
 * Swift/SwiftUI version
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import UIKit
import ImageIO
import MobileCoreServices

public extension UIImage {

    // MARK: - GIF Detection

    /// Checks if a UIImage instance is a GIF
    var isGIF: Bool {
        return images != nil && images!.count > 0
    }

    // MARK: - Create Animated GIF

    /// Creates an animated UIImage from GIF data
    /// - Parameter data: The GIF data
    /// - Returns: An animated UIImage or nil if the data is invalid
    static func sd_animatedGIF(with data: Data?) -> UIImage? {
        guard let data = data else { return nil }

        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            return nil
        }

        let count = CGImageSourceGetCount(source)
        guard count > 0 else { return nil }

        if count == 1 {
            // Single frame image
            return UIImage(data: data)
        }

        // Multiple frames - create animated image
        var images = [UIImage]()
        var duration: TimeInterval = 0.0

        for i in 0..<count {
            guard let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) else {
                continue
            }

            let frameDuration = UIImage.frameDuration(at: i, source: source)
            duration += frameDuration

            let image = UIImage(cgImage: cgImage, scale: UIScreen.main.scale, orientation: .up)
            images.append(image)
        }

        if images.isEmpty {
            return nil
        }

        return UIImage.animatedImage(with: images, duration: duration)
    }

    // MARK: - Extract Images from GIF

    /// Extracts individual frames from GIF data
    /// - Parameter data: The GIF data
    /// - Returns: An array of UIImage frames
    static func images(fromGIFData data: Data?) -> [UIImage]? {
        guard let data = data else { return nil }

        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            return nil
        }

        let count = CGImageSourceGetCount(source)
        guard count > 0 else { return nil }

        var images = [UIImage]()

        for i in 0..<count {
            guard let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) else {
                continue
            }

            let image = UIImage(cgImage: cgImage, scale: UIScreen.main.scale, orientation: .up)
            images.append(image)
        }

        return images.isEmpty ? nil : images
    }

    // MARK: - Create GIF from Images

    /// Creates GIF data from an array of images
    /// - Parameters:
    ///   - images: Array of images to convert to GIF
    ///   - size: Size of the output GIF
    ///   - loopCount: Number of times the GIF should loop (0 for infinite)
    ///   - delayTime: Delay time between frames in seconds
    ///   - gifCachePath: Optional path to save the GIF
    /// - Returns: The GIF data
    static func createGIF(
        with images: [UIImage],
        size: CGSize,
        loopCount: UInt,
        delayTime: Float,
        gifCachePath: String?
    ) -> Data? {
        guard !images.isEmpty else { return nil }

        let fileProperties: [String: Any] = [
            kCGImagePropertyGIFDictionary as String: [
                kCGImagePropertyGIFLoopCount as String: loopCount
            ]
        ]

        let frameProperties: [String: Any] = [
            kCGImagePropertyGIFDictionary as String: [
                kCGImagePropertyGIFDelayTime as String: delayTime
            ]
        ]

        let mutableData = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(mutableData, kUTTypeGIF, images.count, nil) else {
            return nil
        }

        CGImageDestinationSetProperties(destination, fileProperties as CFDictionary)

        for image in images {
            var processedImage = image

            // Resize if needed
            if image.size != size {
                UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
                image.draw(in: CGRect(origin: .zero, size: size))
                processedImage = UIGraphicsGetImageFromCurrentImageContext() ?? image
                UIGraphicsEndImageContext()
            }

            if let cgImage = processedImage.cgImage {
                CGImageDestinationAddImage(destination, cgImage, frameProperties as CFDictionary)
            }
        }

        guard CGImageDestinationFinalize(destination) else {
            return nil
        }

        // Save to file if path is provided
        if let gifCachePath = gifCachePath {
            mutableData.write(toFile: gifCachePath, atomically: true)
        }

        return mutableData as Data
    }

    /// Alternative method to create GIF from images with different approach
    /// - Parameters:
    ///   - images: Array of images to convert to GIF
    ///   - size: Size of the output GIF
    ///   - loopCount: Number of times the GIF should loop (0 for infinite)
    ///   - delayTime: Delay time between frames in seconds
    ///   - gifCachePath: Optional path to save the GIF
    /// - Returns: The GIF data
    static func createGIF2(
        with images: [UIImage],
        size: CGSize,
        loopCount: UInt,
        delayTime: Float,
        gifCachePath: String?
    ) -> Data? {
        // This is an alternative implementation
        // For now, it's the same as createGIF, but could be optimized differently
        return createGIF(with: images, size: size, loopCount: loopCount, delayTime: delayTime, gifCachePath: gifCachePath)
    }

    // MARK: - Private Helpers

    private static func frameDuration(at index: Int, source: CGImageSource) -> TimeInterval {
        var frameDuration: TimeInterval = 0.1 // Default duration

        guard let frameProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil) as? [String: Any],
              let gifProperties = frameProperties[kCGImagePropertyGIFDictionary as String] as? [String: Any] else {
            return frameDuration
        }

        if let unclampedDelayTime = gifProperties[kCGImagePropertyGIFUnclampedDelayTime as String] as? NSNumber {
            frameDuration = unclampedDelayTime.doubleValue
        } else if let delayTime = gifProperties[kCGImagePropertyGIFDelayTime as String] as? NSNumber {
            frameDuration = delayTime.doubleValue
        }

        // Many GIFs have very small delay times, ensure minimum duration
        if frameDuration < 0.011 {
            frameDuration = 0.1
        }

        return frameDuration
    }
}
