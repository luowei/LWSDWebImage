# LWSDWebImage Swift版本使用说明

## 概述

LWSDWebImage提供了Swift版本的实现，专门为使用Swift开发的项目优化，提供更现代化的图片加载和缓存功能。

## 安装

### CocoaPods

在你的`Podfile`中添加：

```ruby
pod 'LWSDWebImage_swift'
```

然后运行：

```bash
pod install
```

## 要求

- iOS 13.0+
- Swift 5.0+
- Xcode 12.0+

## Swift版本包含的功能

Swift版本包含以下组件：

- `SDWebImageCompat.swift` - 兼容性支持
- `SDImageCacheConfig.swift` - 图片缓存配置
- `SDImageCache.swift` - 图片缓存管理
- `SDWebImageDownloader.swift` - 图片下载器
- `SDWebImageManager.swift` - 图片管理器
- `AsyncImage+WebCache.swift` - SwiftUI AsyncImage扩展
- `UIImageView+WebCache.swift` - UIImageView扩展
- `UIButton+WebCache.swift` - UIButton扩展
- `UIImage+GIF.swift` - GIF支持
- `UIImage+MultiFormat.swift` - 多格式支持
- `SDWebImagePrefetcher.swift` - 图片预加载
- `LWSDWebImage.swift` - 主入口

## 使用示例

### UIKit中使用

```swift
import LWSDWebImage_swift

// UIImageView加载图片
imageView.sd_setImage(with: URL(string: "https://example.com/image.jpg"),
                     placeholderImage: UIImage(named: "placeholder"))

// UIButton加载图片
button.sd_setImage(with: URL(string: "https://example.com/icon.png"),
                  for: .normal,
                  placeholderImage: UIImage(named: "default"))
```

### SwiftUI中使用

```swift
import SwiftUI
import LWSDWebImage_swift

struct ContentView: View {
    var body: some View {
        AsyncImage(url: URL(string: "https://example.com/image.jpg")) { image in
            image.resizable()
                 .aspectRatio(contentMode: .fit)
        } placeholder: {
            ProgressView()
        }
        .frame(width: 200, height: 200)
    }
}
```

### 高级用法

```swift
import LWSDWebImage_swift

// 配置缓存
let config = SDImageCacheConfig()
config.maxCacheAge = 60 * 60 * 24 * 7 // 7天
config.maxMemoryCost = 100 * 1024 * 1024 // 100MB

// 清理缓存
SDImageCache.shared.clearMemory()
SDImageCache.shared.clearDisk()

// 预加载图片
let urls = [
    URL(string: "https://example.com/image1.jpg")!,
    URL(string: "https://example.com/image2.jpg")!
]
SDWebImagePrefetcher.shared.prefetchURLs(urls)

// GIF支持
if let gifImage = UIImage.sd_image(withGIFData: gifData) {
    imageView.image = gifImage
}
```

## 与Objective-C版本的区别

- Swift版本要求iOS 13.0+（Objective-C版本支持iOS 8.0+）
- Swift版本提供了SwiftUI AsyncImage支持
- Swift版本使用现代Swift语法和Result类型
- 提供更类型安全的API
- 支持Combine框架

## 注意事项

- 如果你的项目同时使用Objective-C和Swift，可以同时安装`LWSDWebImage`和`LWSDWebImage_swift`
- Swift版本与Objective-C版本可以共存，互不影响
- 建议在App启动时配置缓存策略
- 注意处理图片加载失败的情况

## 许可证

LWSDWebImage_swift遵循MIT许可证。详见LICENSE文件。
