/*
 * This file is part of the SDWebImage package.
 * Swift/SwiftUI version
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import SwiftUI

// MARK: - Image Loading State

public enum ImageLoadingState {
    case idle
    case loading(progress: Double)
    case success(UIImage)
    case failure(Error)
}

// MARK: - Image Loader Observable Object

@available(iOS 13.0, *)
public class WebImageLoader: ObservableObject {
    @Published public var state: ImageLoadingState = .idle
    @Published public var image: UIImage?

    private var operation: SDWebImageOperation?

    public init() {}

    public func load(url: URL?, options: SDWebImageOptions = [], placeholder: UIImage? = nil) {
        guard let url = url else {
            state = .idle
            image = placeholder
            return
        }

        state = .loading(progress: 0.0)
        image = placeholder

        operation = SDWebImageManager.shared.loadImage(
            with: url,
            options: options,
            progress: { [weak self] receivedSize, expectedSize, targetURL in
                let progress = expectedSize > 0 ? Double(receivedSize) / Double(expectedSize) : 0.0
                DispatchQueue.main.async {
                    self?.state = .loading(progress: progress)
                }
            },
            completed: { [weak self] downloadedImage, data, error, cacheType, finished, imageURL in
                guard finished else { return }

                if let error = error {
                    self?.state = .failure(error)
                    self?.image = placeholder
                } else if let downloadedImage = downloadedImage {
                    self?.state = .success(downloadedImage)
                    self?.image = downloadedImage
                } else {
                    self?.state = .idle
                    self?.image = placeholder
                }
            }
        )
    }

    public func cancel() {
        operation?.cancel()
        operation = nil
    }

    deinit {
        cancel()
    }
}

// MARK: - SwiftUI View Extension

@available(iOS 13.0, *)
public extension Image {
    init(uiImage: UIImage?) {
        if let uiImage = uiImage {
            self.init(uiImage: uiImage)
        } else {
            self.init(systemName: "photo")
        }
    }
}

// MARK: - Web Image View

@available(iOS 13.0, *)
public struct WebImage: View {
    @StateObject private var loader = WebImageLoader()

    private let url: URL?
    private let placeholder: UIImage?
    private let options: SDWebImageOptions

    public init(url: URL?, placeholder: UIImage? = nil, options: SDWebImageOptions = []) {
        self.url = url
        self.placeholder = placeholder
        self.options = options
    }

    public var body: some View {
        Group {
            if let image = loader.image {
                Image(uiImage: image)
                    .resizable()
            } else {
                if let placeholder = placeholder {
                    Image(uiImage: placeholder)
                        .resizable()
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                }
            }
        }
        .onAppear {
            loader.load(url: url, options: options, placeholder: placeholder)
        }
        .onDisappear {
            loader.cancel()
        }
    }
}

// MARK: - View Modifier

@available(iOS 13.0, *)
public struct WebImageModifier: ViewModifier {
    let url: URL?
    let placeholder: UIImage?
    let options: SDWebImageOptions

    @StateObject private var loader = WebImageLoader()

    public func body(content: Content) -> some View {
        content
            .onAppear {
                loader.load(url: url, options: options, placeholder: placeholder)
            }
            .onDisappear {
                loader.cancel()
            }
    }
}

@available(iOS 13.0, *)
public extension View {
    func webImage(url: URL?, placeholder: UIImage? = nil, options: SDWebImageOptions = []) -> some View {
        self.modifier(WebImageModifier(url: url, placeholder: placeholder, options: options))
    }
}

// MARK: - Async Image (Modern SwiftUI Style)

@available(iOS 15.0, *)
public struct SDAsyncImage<Content: View, Placeholder: View>: View {
    @StateObject private var loader = WebImageLoader()

    private let url: URL?
    private let options: SDWebImageOptions
    private let content: (UIImage) -> Content
    private let placeholder: () -> Placeholder

    public init(
        url: URL?,
        options: SDWebImageOptions = [],
        @ViewBuilder content: @escaping (UIImage) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.options = options
        self.content = content
        self.placeholder = placeholder
    }

    public var body: some View {
        Group {
            switch loader.state {
            case .idle:
                placeholder()
            case .loading:
                placeholder()
            case .success(let image):
                content(image)
            case .failure:
                placeholder()
            }
        }
        .onAppear {
            loader.load(url: url, options: options)
        }
        .onDisappear {
            loader.cancel()
        }
    }
}

@available(iOS 15.0, *)
public extension SDAsyncImage where Placeholder == Color {
    init(
        url: URL?,
        options: SDWebImageOptions = [],
        @ViewBuilder content: @escaping (UIImage) -> Content
    ) {
        self.init(
            url: url,
            options: options,
            content: content,
            placeholder: { Color.gray.opacity(0.2) }
        )
    }
}

@available(iOS 15.0, *)
public extension SDAsyncImage where Content == Image, Placeholder == Color {
    init(url: URL?, options: SDWebImageOptions = []) {
        self.init(
            url: url,
            options: options,
            content: { uiImage in
                Image(uiImage: uiImage)
                    .resizable()
            },
            placeholder: { Color.gray.opacity(0.2) }
        )
    }
}
