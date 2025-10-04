/*
 * This file is part of the SDWebImage package.
 * Swift/SwiftUI version
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import UIKit
import ImageIO

// MARK: - Image Format

public enum SDImageFormat: Int {
    case undefined = -1
    case jpeg = 0
    case png
    case gif
    case tiff
    case webp
    case heic
    case heif
}

// MARK: - Data Extension

public extension Data {

    /// Detect image content type from image data
    var sd_imageFormat: SDImageFormat {
        guard !isEmpty else { return .undefined }

        var c: UInt8 = 0
        copyBytes(to: &c, count: 1)

        switch c {
        case 0xFF:
            return .jpeg
        case 0x89:
            return .png
        case 0x47:
            return .gif
        case 0x49, 0x4D:
            return .tiff
        case 0x52:
            // R as RIFF for WEBP
            if count >= 12 {
                let riff = String(data: subdata(in: 0..<4), encoding: .ascii)
                let webp = String(data: subdata(in: 8..<12), encoding: .ascii)
                if riff == "RIFF" && webp == "WEBP" {
                    return .webp
                }
            }
            return .undefined
        case 0x00:
            // HEIC/HEIF detection
            if count >= 12 {
                let ftyp = String(data: subdata(in: 4..<8), encoding: .ascii)
                if ftyp == "ftyp" {
                    let brand = String(data: subdata(in: 8..<12), encoding: .ascii)
                    if brand == "heic" || brand == "heix" {
                        return .heic
                    } else if brand == "heif" || brand == "heim" || brand == "heis" {
                        return .heif
                    }
                }
            }
            return .undefined
        default:
            return .undefined
        }
    }
}

// MARK: - UIImage Extension

public extension UIImage {

    /// Create UIImage from data, supporting multiple formats including GIF
    /// - Parameter data: The image data
    /// - Returns: A UIImage instance or nil
    static func sd_image(with data: Data?) -> UIImage? {
        guard let data = data else { return nil }

        let format = data.sd_imageFormat

        switch format {
        case .gif:
            return UIImage.sd_animatedGIF(with: data)
        default:
            return UIImage(data: data)
        }
    }

    /// Create UIImage from data with scale
    /// - Parameters:
    ///   - data: The image data
    ///   - scale: The scale factor
    /// - Returns: A UIImage instance or nil
    static func sd_image(with data: Data?, scale: CGFloat) -> UIImage? {
        guard let data = data else { return nil }

        let format = data.sd_imageFormat

        switch format {
        case .gif:
            return UIImage.sd_animatedGIF(with: data)
        default:
            guard let image = UIImage(data: data) else { return nil }
            if let cgImage = image.cgImage {
                return UIImage(cgImage: cgImage, scale: scale, orientation: image.imageOrientation)
            }
            return image
        }
    }

    /// Get image data in appropriate format
    /// - Parameter format: The desired image format
    /// - Returns: Image data in the specified format
    func sd_imageData(as format: SDImageFormat = .png) -> Data? {
        switch format {
        case .jpeg:
            return jpegData(compressionQuality: 1.0)
        case .png:
            return pngData()
        default:
            return pngData()
        }
    }
}
