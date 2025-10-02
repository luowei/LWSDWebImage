# LWSDWebImage

[![CI Status](https://img.shields.io/travis/luowei/LWSDWebImage.svg?style=flat)](https://travis-ci.org/luowei/LWSDWebImage)
[![Version](https://img.shields.io/cocoapods/v/LWSDWebImage.svg?style=flat)](https://cocoapods.org/pods/LWSDWebImage)
[![License](https://img.shields.io/cocoapods/l/LWSDWebImage.svg?style=flat)](https://cocoapods.org/pods/LWSDWebImage)
[![Platform](https://img.shields.io/cocoapods/p/LWSDWebImage.svg?style=flat)](https://cocoapods.org/pods/LWSDWebImage)

## 简介

LWSDWebImage 是一个基于 SDWebImage 的图片加载和缓存库，提供异步图片下载、内存和磁盘缓存功能。它为 iOS 开发提供了便捷的图片加载解决方案，支持 UIImageView、UIButton 等 UI 组件的扩展。

## 主要特性

### 核心功能

- **异步图片下载**: 使用后台线程下载图片，不阻塞主线程
- **自动缓存管理**: 支持内存缓存和磁盘缓存两级缓存机制
- **多种加载选项**: 提供丰富的配置选项，满足不同场景需求
- **分类扩展**: 为常用 UI 组件提供便捷的分类方法
- **GIF 支持**: 支持 GIF 动画图片的加载和显示
- **图片预加载**: 支持批量预加载图片到缓存

### 高级特性

- **渐进式下载**: 支持图片渐进式加载，提升用户体验
- **下载进度回调**: 实时获取图片下载进度
- **后台下载**: 支持应用进入后台时继续下载
- **SSL 证书处理**: 支持自定义 SSL 证书验证
- **Cookie 管理**: 支持 HTTP Cookie 处理
- **图片转换**: 支持下载完成后的图片转换处理
- **缓存查询**: 可查询图片是否已缓存
- **多格式支持**: 支持多种图片格式

## 系统要求

- iOS 8.0 或更高版本
- Xcode 7.0 或更高版本

## 安装

### CocoaPods

LWSDWebImage 可通过 [CocoaPods](https://cocoapods.org) 安装。在您的 Podfile 中添加以下内容：

```ruby
pod 'LWSDWebImage'
```

然后执行：

```bash
pod install
```

## 使用方法

### 基本用法

#### UIImageView 加载图片

```objective-c
#import <LWSDWebImage/UIImageView+WebCache.h>

// 最简单的用法
[imageView sd_setImageWithURL:[NSURL URLWithString:@"http://example.com/image.jpg"]];

// 带占位图
[imageView sd_setImageWithURL:[NSURL URLWithString:@"http://example.com/image.jpg"]
             placeholderImage:[UIImage imageNamed:@"placeholder"]];

// 带完成回调
[imageView sd_setImageWithURL:[NSURL URLWithString:@"http://example.com/image.jpg"]
                    completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                        if (image) {
                            // 图片加载成功
                            NSLog(@"图片来源: %@", cacheType == SDImageCacheTypeMemory ? @"内存" :
                                                  cacheType == SDImageCacheTypeDisk ? @"磁盘" : @"网络");
                        } else {
                            // 加载失败
                            NSLog(@"加载失败: %@", error);
                        }
                    }];

// 带进度和完成回调
[imageView sd_setImageWithURL:[NSURL URLWithString:@"http://example.com/image.jpg"]
             placeholderImage:[UIImage imageNamed:@"placeholder"]
                      options:SDWebImageProgressiveDownload
                     progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL *targetURL) {
                         // 下载进度更新 (后台线程)
                         float progress = (float)receivedSize / expectedSize;
                         NSLog(@"下载进度: %.2f%%", progress * 100);
                     }
                    completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                        // 下载完成 (主线程)
                    }];
```

#### UIButton 加载图片

```objective-c
#import <LWSDWebImage/UIButton+WebCache.h>

// 设置按钮图片
[button sd_setImageWithURL:[NSURL URLWithString:@"http://example.com/image.jpg"]
                  forState:UIControlStateNormal];

// 设置按钮背景图片
[button sd_setBackgroundImageWithURL:[NSURL URLWithString:@"http://example.com/image.jpg"]
                            forState:UIControlStateNormal
                    placeholderImage:[UIImage imageNamed:@"placeholder"]];

// 带选项和回调
[button sd_setImageWithURL:[NSURL URLWithString:@"http://example.com/image.jpg"]
                  forState:UIControlStateNormal
          placeholderImage:[UIImage imageNamed:@"placeholder"]
                   options:SDWebImageRetryFailed
                 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                     // 加载完成
                 }];
```

#### 在 UITableView 中使用

```objective-c
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *MyIdentifier = @"MyIdentifier";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:MyIdentifier];
    }

    // 使用 sd_setImageWithURL: 加载图片
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:@"http://example.com/image.jpg"]
                      placeholderImage:[UIImage imageNamed:@"placeholder"]];

    cell.textLabel.text = @"单元格文本";
    return cell;
}
```

### 高级用法

#### 使用 SDWebImageManager

```objective-c
SDWebImageManager *manager = [SDWebImageManager sharedManager];
[manager loadImageWithURL:imageURL
                  options:0
                 progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL *targetURL) {
                     // 进度回调
                 }
                completed:^(UIImage *image, NSData *data, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                     if (image) {
                         // 图片加载成功，可以进行处理
                     }
                 }];
```

#### 独立使用 SDImageCache

```objective-c
// 存储图片
[[SDImageCache sharedImageCache] storeImage:image forKey:@"myImageKey" completion:^{
    NSLog(@"图片已缓存");
}];

// 查询图片
[[SDImageCache sharedImageCache] queryCacheOperationForKey:@"myImageKey"
                                                      done:^(UIImage *image, NSData *data, SDImageCacheType cacheType) {
    if (image) {
        // 图片存在于缓存中
    }
}];

// 从内存缓存获取
UIImage *imageFromMemory = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:@"myImageKey"];

// 从磁盘缓存获取
UIImage *imageFromDisk = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:@"myImageKey"];

// 移除图片
[[SDImageCache sharedImageCache] removeImageForKey:@"myImageKey" withCompletion:^{
    NSLog(@"图片已移除");
}];

// 清空缓存
[[SDImageCache sharedImageCache] clearMemory];  // 清空内存缓存
[[SDImageCache sharedImageCache] clearDiskOnCompletion:^{
    NSLog(@"磁盘缓存已清空");
}];

// 获取缓存大小
NSUInteger cacheSize = [[SDImageCache sharedImageCache] getSize];
NSLog(@"缓存大小: %lu bytes", (unsigned long)cacheSize);
```

#### 独立使用 SDWebImageDownloader

```objective-c
SDWebImageDownloader *downloader = [SDWebImageDownloader sharedDownloader];

SDWebImageDownloadToken *token = [downloader downloadImageWithURL:imageURL
                                                           options:0
                                                          progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL *targetURL) {
                                                              // 进度
                                                          }
                                                         completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                                                             if (image && finished) {
                                                                 // 下载完成
                                                             }
                                                         }];

// 取消下载
[downloader cancel:token];
```

#### 图片预加载

```objective-c
// 预加载图片数组
NSArray *imageURLs = @[
    [NSURL URLWithString:@"http://example.com/image1.jpg"],
    [NSURL URLWithString:@"http://example.com/image2.jpg"],
    [NSURL URLWithString:@"http://example.com/image3.jpg"]
];

[[SDWebImagePrefetcher sharedImagePrefetcher] prefetchURLs:imageURLs
                                                  progress:^(NSUInteger noOfFinishedUrls, NSUInteger noOfTotalUrls) {
                                                      NSLog(@"预加载进度: %lu/%lu", (unsigned long)noOfFinishedUrls, (unsigned long)noOfTotalUrls);
                                                  }
                                                 completed:^(NSUInteger noOfFinishedUrls, NSUInteger noOfSkippedUrls) {
                                                      NSLog(@"预加载完成: %lu 成功, %lu 跳过", (unsigned long)noOfFinishedUrls, (unsigned long)noOfSkippedUrls);
                                                  }];
```

### 加载选项 (SDWebImageOptions)

```objective-c
// 重试失败的 URL（默认情况下，失败的 URL 会被加入黑名单）
SDWebImageRetryFailed

// 低优先级下载（UI 交互时不下载）
SDWebImageLowPriority

// 仅使用内存缓存
SDWebImageCacheMemoryOnly

// 渐进式下载（边下载边显示）
SDWebImageProgressiveDownload

// 刷新缓存（即使有缓存也重新下载）
SDWebImageRefreshCached

// 后台下载（应用进入后台时继续下载）
SDWebImageContinueInBackground

// 处理存储在 NSHTTPCookieStore 中的 cookies
SDWebImageHandleCookies

// 允许不受信任的 SSL 证书（仅用于测试）
SDWebImageAllowInvalidSSLCertificates

// 高优先级（将任务移到队列前端）
SDWebImageHighPriority

// 延迟加载占位图
SDWebImageDelayPlaceholder

// 转换动画图片
SDWebImageTransformAnimatedImage

// 手动设置图片（不自动设置）
SDWebImageAvoidAutoSetImage

// 缩小大图片
SDWebImageScaleDownLargeImages
```

### GIF 支持

```objective-c
#import <LWSDWebImage/UIImage+GIF.h>

// 从 NSData 创建 GIF
UIImage *gifImage = [UIImage sd_animatedGIFWithData:gifData];

// 检查是否为 GIF
BOOL isGIF = [image isGIF];

// 从 GIF 数据中提取帧
NSArray<UIImage *> *frames = [UIImage imagesFromGIFData:gifData];

// 创建 GIF
NSData *gifData = [UIImage createGIFWithImages:imageArray
                                          size:CGSizeMake(200, 200)
                                     loopCount:0  // 0 = 无限循环
                                     delayTime:0.1
                                  gifCachePath:cachePath];
```

### 缓存配置

```objective-c
SDImageCacheConfig *cacheConfig = [[SDImageCache sharedImageCache] config];

// 设置是否解压缩图片（默认 YES）
cacheConfig.shouldDecompressImages = YES;

// 设置是否禁用 iCloud 备份（默认 YES）
cacheConfig.shouldDisableiCloud = YES;

// 设置是否使用内存缓存（默认 YES）
cacheConfig.shouldCacheImagesInMemory = YES;

// 设置缓存最大保留时间（秒，默认 1 周）
cacheConfig.maxCacheAge = 60 * 60 * 24 * 7;

// 设置缓存最大大小（字节）
cacheConfig.maxCacheSize = 1024 * 1024 * 100; // 100 MB
```

### 下载器配置

```objective-c
SDWebImageDownloader *downloader = [SDWebImageDownloader sharedDownloader];

// 设置最大并发下载数（默认 6）
downloader.maxConcurrentDownloads = 3;

// 设置下载超时时间（默认 15 秒）
downloader.downloadTimeout = 30.0;

// 设置是否解压缩图片（默认 YES）
downloader.shouldDecompressImages = YES;

// 设置执行顺序（FIFO 或 LIFO）
downloader.executionOrder = SDWebImageDownloaderFIFOExecutionOrder;

// 设置 HTTP 请求头
[downloader setValue:@"YourUserAgent" forHTTPHeaderField:@"User-Agent"];

// 设置认证
downloader.username = @"username";
downloader.password = @"password";
```

### 自定义缓存键

```objective-c
// 设置缓存键过滤器
[[SDWebImageManager sharedManager] setCacheKeyFilter:^NSString *(NSURL *url) {
    // 移除 URL 中的查询参数
    url = [[NSURL alloc] initWithScheme:url.scheme host:url.host path:url.path];
    return [url absoluteString];
}];
```

### 图片转换

```objective-c
// 实现 SDWebImageManagerDelegate
@interface MyClass () <SDWebImageManagerDelegate>
@end

@implementation MyClass

- (void)setupImageManager {
    [SDWebImageManager sharedManager].delegate = self;
}

// 在下载后转换图片（在后台线程执行）
- (UIImage *)imageManager:(SDWebImageManager *)imageManager
   transformDownloadedImage:(UIImage *)image
                    withURL:(NSURL *)imageURL {
    // 例如：添加圆角
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    [[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, image.size.width, image.size.height)
                                cornerRadius:image.size.width / 2] addClip];
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    UIImage *roundedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return roundedImage;
}

// 控制是否下载图片
- (BOOL)imageManager:(SDWebImageManager *)imageManager
shouldDownloadImageForURL:(NSURL *)imageURL {
    // 可以根据 URL 或其他条件决定是否下载
    return YES;
}

@end
```

## API 文档

### SDWebImageManager

核心管理类，连接下载器和缓存。

```objective-c
// 获取单例
+ (instancetype)sharedManager;

// 加载图片
- (id<SDWebImageOperation>)loadImageWithURL:(NSURL *)url
                                    options:(SDWebImageOptions)options
                                   progress:(SDWebImageDownloaderProgressBlock)progressBlock
                                  completed:(SDInternalCompletionBlock)completedBlock;

// 保存图片到缓存
- (void)saveImageToCache:(UIImage *)image forURL:(NSURL *)url;

// 取消所有操作
- (void)cancelAll;

// 检查是否有正在运行的操作
- (BOOL)isRunning;

// 检查图片是否已缓存
- (void)cachedImageExistsForURL:(NSURL *)url
                     completion:(SDWebImageCheckCacheCompletionBlock)completionBlock;

// 检查磁盘缓存
- (void)diskImageExistsForURL:(NSURL *)url
                   completion:(SDWebImageCheckCacheCompletionBlock)completionBlock;

// 获取缓存键
- (NSString *)cacheKeyForURL:(NSURL *)url;
```

### SDImageCache

图片缓存管理类。

```objective-c
// 获取单例
+ (instancetype)sharedImageCache;

// 存储图片
- (void)storeImage:(UIImage *)image
            forKey:(NSString *)key
        completion:(SDWebImageNoParamsBlock)completionBlock;

// 查询缓存
- (NSOperation *)queryCacheOperationForKey:(NSString *)key
                                      done:(SDCacheQueryCompletedBlock)doneBlock;

// 从内存缓存获取
- (UIImage *)imageFromMemoryCacheForKey:(NSString *)key;

// 从磁盘缓存获取
- (UIImage *)imageFromDiskCacheForKey:(NSString *)key;

// 移除图片
- (void)removeImageForKey:(NSString *)key
           withCompletion:(SDWebImageNoParamsBlock)completion;

// 清空缓存
- (void)clearMemory;
- (void)clearDiskOnCompletion:(SDWebImageNoParamsBlock)completion;

// 删除过期文件
- (void)deleteOldFilesWithCompletionBlock:(SDWebImageNoParamsBlock)completionBlock;

// 获取缓存信息
- (NSUInteger)getSize;
- (NSUInteger)getDiskCount;
- (void)calculateSizeWithCompletionBlock:(SDWebImageCalculateSizeBlock)completionBlock;
```

### SDWebImageDownloader

图片下载器类。

```objective-c
// 获取单例
+ (instancetype)sharedDownloader;

// 下载图片
- (SDWebImageDownloadToken *)downloadImageWithURL:(NSURL *)url
                                          options:(SDWebImageDownloaderOptions)options
                                         progress:(SDWebImageDownloaderProgressBlock)progressBlock
                                        completed:(SDWebImageDownloaderCompletedBlock)completedBlock;

// 取消下载
- (void)cancel:(SDWebImageDownloadToken *)token;

// 取消所有下载
- (void)cancelAllDownloads;

// 设置暂停状态
- (void)setSuspended:(BOOL)suspended;

// 设置 HTTP 头
- (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field;
```

### SDWebImagePrefetcher

图片预加载类。

```objective-c
// 获取单例
+ (instancetype)sharedImagePrefetcher;

// 预加载图片
- (void)prefetchURLs:(NSArray<NSURL *> *)urls
            progress:(SDWebImagePrefetcherProgressBlock)progressBlock
           completed:(SDWebImagePrefetcherCompletionBlock)completionBlock;

// 取消预加载
- (void)cancelPrefetching;
```

## 缓存类型

```objective-c
typedef NS_ENUM(NSInteger, SDImageCacheType) {
    SDImageCacheTypeNone,    // 图片来自网络
    SDImageCacheTypeDisk,    // 图片来自磁盘缓存
    SDImageCacheTypeMemory   // 图片来自内存缓存
};
```

## 最佳实践

### 1. 内存管理

```objective-c
// 在收到内存警告时清理缓存
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    [[SDImageCache sharedImageCache] clearMemory];
}

// 在应用进入后台时清理过期缓存
- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[SDImageCache sharedImageCache] deleteOldFilesWithCompletionBlock:nil];
}
```

### 2. 网络优化

```objective-c
// 对于列表滚动，使用低优先级选项
[imageView sd_setImageWithURL:url
             placeholderImage:placeholder
                      options:SDWebImageLowPriority];

// 预加载下一页图片
[[SDWebImagePrefetcher sharedImagePrefetcher] prefetchURLs:nextPageURLs];
```

### 3. 取消操作

```objective-c
// UITableView 或 UICollectionView 的 cell 重用时自动取消
// UIImageView+WebCache 会在设置新 URL 时自动取消之前的下载

// 手动取消
- (void)prepareForReuse {
    [super prepareForReuse];
    [self.imageView sd_cancelCurrentImageLoad];
}
```

### 4. 自定义命名空间

```objective-c
// 为不同业务使用不同的缓存命名空间
SDImageCache *avatarCache = [[SDImageCache alloc] initWithNamespace:@"avatar"];
SDImageCache *productCache = [[SDImageCache alloc] initWithNamespace:@"product"];
```

## 常见问题

### 1. 图片不显示？

- 检查 URL 是否正确
- 检查网络权限配置（HTTP vs HTTPS）
- 查看控制台错误日志

### 2. 内存占用过高？

```objective-c
// 禁用内存缓存
[[SDImageCache sharedImageCache] config].shouldCacheImagesInMemory = NO;

// 或使用仅磁盘缓存选项
[imageView sd_setImageWithURL:url
             placeholderImage:placeholder
                      options:SDWebImageCacheMemoryOnly];
```

### 3. 如何加载本地图片？

```objective-c
// 使用 file:// URL
NSURL *localURL = [NSURL fileURLWithPath:localPath];
[imageView sd_setImageWithURL:localURL];
```

### 4. 如何强制刷新缓存？

```objective-c
[imageView sd_setImageWithURL:url
             placeholderImage:placeholder
                      options:SDWebImageRefreshCached];
```

## 示例项目

要运行示例项目，请克隆仓库，然后在 Example 目录下执行 `pod install`：

```bash
git clone https://gitlab.com/ioslibraries1/lwsdwebimage.git
cd LWSDWebImage/Example
pod install
open LWSDWebImage.xcworkspace
```

## 性能优化建议

1. **合理设置缓存大小**：根据应用需求调整 `maxCacheSize` 和 `maxCacheAge`
2. **使用适当的图片格式**：WebP 比 JPEG/PNG 更小
3. **预加载关键图片**：使用 `SDWebImagePrefetcher` 预加载即将显示的图片
4. **监控缓存大小**：定期清理过期和不常用的图片
5. **使用 CDN**：将图片托管在 CDN 上提高下载速度

## 线程安全

- 所有 SDWebImage 的公共 API 都是线程安全的
- 可以在任何线程调用这些方法
- 完成回调默认在主线程执行（除非特别说明）
- 进度回调在后台线程执行

## 作者

luowei, luowei@wodedata.com

## 许可证

LWSDWebImage 基于 MIT 许可证开源。详见 [LICENSE](LICENSE) 文件。

## 致谢

本项目基于 [SDWebImage](https://github.com/SDWebImage/SDWebImage) 开发。感谢 SDWebImage 团队的出色工作。

---

如有问题或建议，欢迎提交 Issue 或 Pull Request。
