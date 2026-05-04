# LWSDWebImage


## graphify Knowledge Graph

- Interactive graph: https://luowei.github.io/LWSDWebImage/
- Report: https://luowei.github.io/LWSDWebImage/GRAPH_REPORT.md
- Graph data: https://luowei.github.io/LWSDWebImage/graph.json

[![CI Status](https://img.shields.io/travis/luowei/LWSDWebImage.svg?style=flat)](https://travis-ci.org/luowei/LWSDWebImage)
[![Version](https://img.shields.io/cocoapods/v/LWSDWebImage.svg?style=flat)](https://cocoapods.org/pods/LWSDWebImage)
[![License](https://img.shields.io/cocoapods/l/LWSDWebImage.svg?style=flat)](https://cocoapods.org/pods/LWSDWebImage)
[![Platform](https://img.shields.io/cocoapods/p/LWSDWebImage.svg?style=flat)](https://cocoapods.org/pods/LWSDWebImage)

**[English](./README.md) | [中文版](./README_ZH.md)**

---

A powerful asynchronous image downloader and caching library based on SDWebImage. LWSDWebImage provides a comprehensive wrapper around SDWebImage, offering efficient image loading with advanced memory and disk caching capabilities, progressive loading, and extensive customization options for iOS applications.

## Table of Contents

- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Architecture](#architecture)
- [Usage](#usage)
- [Advanced Features](#advanced-features)
- [API Reference](#api-reference)
- [Best Practices](#best-practices)
- [Example Project](#example-project)
- [FAQ](#faq)
- [License](#license)

## Features

### Core Image Loading & Caching

- **Asynchronous Image Downloading**: Non-blocking image downloads using background threads
- **Dual-Layer Caching System**:
  - Fast in-memory cache for instant image retrieval
  - Persistent disk cache for offline access and reduced network usage
- **Automatic Cache Management**: Intelligent cache expiration, size limits, and memory pressure handling
- **Cache Query & Storage**: Direct access to cache with flexible key-based storage and retrieval

### SDWebImage Wrapper Functionality

LWSDWebImage serves as a comprehensive wrapper around SDWebImage, providing:

- **Complete SDWebImage API Access**: Full compatibility with all SDWebImage features
- **Simplified Integration**: Easy-to-use category methods for common UI components
- **Enhanced Category Support**:
  - `UIImageView+WebCache` for image views
  - `UIButton+WebCache` for button images and backgrounds
  - `NSImage+WebCache` for macOS compatibility
  - `UIImageView+HighlightedWebCache` for highlighted states
- **Unified Image Management**: Centralized `SDWebImageManager` for coordinating downloads and caching
- **Flexible Download Control**: Direct access to `SDWebImageDownloader` for custom download scenarios

### Advanced Features

- **Progressive Image Loading**: Display images progressively as they download for better UX
- **Animated Image Support**: Native GIF animation support with `UIImage+GIF`
- **Background Download Continuation**: Downloads continue even when app is in background
- **Image Transformation Pipeline**: Custom image processing and filtering during download
- **Image Prefetching**: Batch prefetch images before they're needed with `SDWebImagePrefetcher`
- **URL Blacklist Management**: Automatic retry prevention for failed URLs
- **Cache Key Filtering**: Normalize URLs for consistent caching (remove query parameters, etc.)
- **SSL Certificate Validation**: Customizable SSL handling for secure connections
- **Priority Queue System**: Control download priority for optimal performance
- **Multiple Image Format Support**: JPEG, PNG, GIF, WebP, and more
- **Download Progress Tracking**: Real-time progress callbacks for UI updates
- **Cookie Management**: HTTP cookie handling for authenticated requests
- **Thread Safety**: All operations are thread-safe for concurrent use

## Requirements

- iOS 8.0 or later
- Xcode 7.0 or later
- Objective-C or Swift projects

## Installation

LWSDWebImage is available through [CocoaPods](https://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod 'LWSDWebImage'
```

For Swift version, use:

```ruby
pod 'LWSDWebImage_swift'
```

See [Swift Version Documentation](README_SWIFT_VERSION.md) for more details.

Then run:

```bash
pod install
```

## Architecture

LWSDWebImage is built on top of SDWebImage and follows a layered architecture:

```
┌─────────────────────────────────────────────────────────┐
│  UI Categories (UIImageView, UIButton, etc.)            │
├─────────────────────────────────────────────────────────┤
│  SDWebImageManager (Coordination Layer)                 │
├──────────────────────┬──────────────────────────────────┤
│  SDImageCache       │  SDWebImageDownloader             │
├──────────────────────┴──────────────────────────────────┤
│  SDWebImageDecoder & Image Format Handlers              │
└─────────────────────────────────────────────────────────┘
```

**Key Components**:

1. **UI Categories**: Convenient methods for loading images into UI components
2. **SDWebImageManager**: Central manager coordinating cache checks and downloads
3. **SDImageCache**: Manages both memory and disk caching
4. **SDWebImageDownloader**: Handles asynchronous image downloads with NSURLSession
5. **SDWebImagePrefetcher**: Batch image prefetching for performance optimization
6. **Image Decoders**: Format-specific decoders (JPEG, PNG, GIF, etc.)

## Usage

### Basic Image Loading

Load an image from a URL into a UIImageView:

```objective-c
#import <LWSDWebImage/UIImageView+WebCache.h>

[imageView sd_setImageWithURL:[NSURL URLWithString:@"http://example.com/image.jpg"]];
```

### With Placeholder Image

```objective-c
[imageView sd_setImageWithURL:[NSURL URLWithString:@"http://example.com/image.jpg"]
             placeholderImage:[UIImage imageNamed:@"placeholder"]];
```

### With Completion Block

```objective-c
[imageView sd_setImageWithURL:[NSURL URLWithString:@"http://example.com/image.jpg"]
             placeholderImage:[UIImage imageNamed:@"placeholder"]
                    completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                        if (error) {
                            NSLog(@"Error loading image: %@", error);
                        } else {
                            NSLog(@"Image loaded from: %@", cacheType == SDImageCacheTypeMemory ? @"Memory" : @"Disk");
                        }
                    }];
```

### With Options and Progress

```objective-c
[imageView sd_setImageWithURL:[NSURL URLWithString:@"http://example.com/image.jpg"]
             placeholderImage:[UIImage imageNamed:@"placeholder"]
                      options:SDWebImageProgressiveDownload | SDWebImageContinueInBackground
                     progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL *targetURL) {
                         float progress = (float)receivedSize / expectedSize;
                         NSLog(@"Download progress: %.2f%%", progress * 100);
                     }
                    completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                         // Handle completion
                    }];
```

### Image Loading Options

The library provides various options for customizing image loading behavior:

- `SDWebImageRetryFailed`: Retry downloading images even if they previously failed
- `SDWebImageLowPriority`: Download images with low priority during UI interactions
- `SDWebImageCacheMemoryOnly`: Cache images only in memory, not on disk
- `SDWebImageProgressiveDownload`: Show images progressively as they download
- `SDWebImageRefreshCached`: Respect HTTP cache control and refresh cached images if needed
- `SDWebImageContinueInBackground`: Continue downloading in background
- `SDWebImageHandleCookies`: Handle cookies from NSHTTPCookieStore
- `SDWebImageAllowInvalidSSLCertificates`: Allow untrusted SSL certificates (use with caution)
- `SDWebImageHighPriority`: Load images with high priority
- `SDWebImageDelayPlaceholder`: Delay loading placeholder until after image loads
- `SDWebImageAvoidAutoSetImage`: Manually set the image in completion block
- `SDWebImageScaleDownLargeImages`: Scale down large images to fit device memory

### Using UIButton Category

```objective-c
#import <LWSDWebImage/UIButton+WebCache.h>

[button sd_setImageWithURL:[NSURL URLWithString:@"http://example.com/icon.jpg"]
                  forState:UIControlStateNormal];

[button sd_setBackgroundImageWithURL:[NSURL URLWithString:@"http://example.com/bg.jpg"]
                            forState:UIControlStateNormal];
```

### Direct Cache and Download Management

```objective-c
#import <LWSDWebImage/SDWebImageManager.h>

SDWebImageManager *manager = [SDWebImageManager sharedManager];
[manager loadImageWithURL:imageURL
                  options:0
                 progress:nil
                completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                    if (image) {
                        // Use the image
                    }
                }];
```

### Cache Operations

```objective-c
#import <LWSDWebImage/SDImageCache.h>

SDImageCache *cache = [SDImageCache sharedImageCache];

// Store an image
[cache storeImage:image forKey:@"uniqueKey" completion:^{
    NSLog(@"Image stored successfully");
}];

// Query cache
[cache queryCacheOperationForKey:@"uniqueKey" done:^(UIImage *image, NSData *data, SDImageCacheType cacheType) {
    if (image) {
        NSLog(@"Image found in cache");
    }
}];

// Remove from cache
[cache removeImageForKey:@"uniqueKey" withCompletion:^{
    NSLog(@"Image removed from cache");
}];

// Clear memory cache
[cache clearMemory];

// Clear disk cache
[cache clearDiskOnCompletion:^{
    NSLog(@"Disk cache cleared");
}];

// Get cache size
NSUInteger size = [cache getSize];
NSUInteger count = [cache getDiskCount];
NSLog(@"Cache size: %lu bytes, count: %lu", (unsigned long)size, (unsigned long)count);
```

### Custom Cache Key

```objective-c
[[SDWebImageManager sharedManager] setCacheKeyFilter:^NSString *(NSURL *url) {
    // Remove query parameters for consistent caching
    url = [[NSURL alloc] initWithScheme:url.scheme host:url.host path:url.path];
    return [url absoluteString];
}];
```

### Image Prefetching

```objective-c
#import <LWSDWebImage/SDWebImagePrefetcher.h>

NSArray *imageURLs = @[
    [NSURL URLWithString:@"http://example.com/image1.jpg"],
    [NSURL URLWithString:@"http://example.com/image2.jpg"],
    [NSURL URLWithString:@"http://example.com/image3.jpg"]
];

[[SDWebImagePrefetcher sharedImagePrefetcher] prefetchURLs:imageURLs
                                                  progress:^(NSUInteger noOfFinishedUrls, NSUInteger noOfTotalUrls) {
                                                      NSLog(@"Prefetch progress: %lu/%lu",
                                                            (unsigned long)noOfFinishedUrls,
                                                            (unsigned long)noOfTotalUrls);
                                                  }
                                                 completed:^(NSUInteger noOfFinishedUrls, NSUInteger noOfSkippedUrls) {
                                                      NSLog(@"Prefetch completed: %lu finished, %lu skipped",
                                                            (unsigned long)noOfFinishedUrls,
                                                            (unsigned long)noOfSkippedUrls);
                                                  }];
```

### Using in UITableView/UICollectionView

LWSDWebImage automatically handles cell reuse and cancels previous loads:

```objective-c
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];

    // Previous image loading is automatically cancelled when setting a new URL
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:@"http://example.com/image.jpg"]
                      placeholderImage:[UIImage imageNamed:@"placeholder"]
                               options:SDWebImageLowPriority]; // Low priority during scrolling

    cell.textLabel.text = @"Cell text";
    return cell;
}

// Manually cancel if needed in prepareForReuse
- (void)prepareForReuse {
    [super prepareForReuse];
    [self.imageView sd_cancelCurrentImageLoad];
}
```

## Advanced Features

### 1. Custom Image Transformation

Implement the `SDWebImageManagerDelegate` to transform images during download:

```objective-c
@interface MyViewController () <SDWebImageManagerDelegate>
@end

@implementation MyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [SDWebImageManager sharedManager].delegate = self;
}

// Transform downloaded images (runs on background thread)
- (UIImage *)imageManager:(SDWebImageManager *)imageManager
   transformDownloadedImage:(UIImage *)image
                    withURL:(NSURL *)imageURL {
    // Example: Apply circular mask
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    [[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, image.size.width, image.size.height)
                                cornerRadius:image.size.width / 2] addClip];
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    UIImage *transformedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return transformedImage;
}

// Control whether to download an image
- (BOOL)imageManager:(SDWebImageManager *)imageManager
shouldDownloadImageForURL:(NSURL *)imageURL {
    // Custom logic to determine if download should proceed
    return YES;
}

@end
```

### 2. GIF Animation Support

```objective-c
#import <LWSDWebImage/UIImage+GIF.h>

// Load animated GIF
[imageView sd_setImageWithURL:[NSURL URLWithString:@"http://example.com/animation.gif"]];

// Create GIF from images programmatically
NSArray<UIImage *> *images = @[image1, image2, image3];
NSData *gifData = [UIImage createGIFWithImages:images
                                          size:CGSizeMake(300, 300)
                                     loopCount:0  // 0 = infinite loop
                                     delayTime:0.1
                                  gifCachePath:cachePath];

// Check if image is GIF
if ([image isGIF]) {
    NSLog(@"This is an animated GIF");
}

// Extract frames from GIF data
NSArray<UIImage *> *frames = [UIImage imagesFromGIFData:gifData];
```

### 3. Cache Configuration

Configure cache behavior globally:

```objective-c
#import <LWSDWebImage/SDImageCacheConfig.h>

SDImageCache *imageCache = [SDImageCache sharedImageCache];
SDImageCacheConfig *cacheConfig = imageCache.config;

// Memory cache settings
cacheConfig.shouldCacheImagesInMemory = YES;
cacheConfig.shouldDecompressImages = YES;  // Decompress for faster display

// Disk cache settings
cacheConfig.shouldDisableiCloud = YES;  // Prevent iCloud backup
cacheConfig.maxCacheAge = 60 * 60 * 24 * 7;  // 1 week (in seconds)
cacheConfig.maxCacheSize = 1024 * 1024 * 100;  // 100 MB

// Get cache statistics
NSUInteger cacheSize = [imageCache getSize];
NSUInteger fileCount = [imageCache getDiskCount];
NSLog(@"Cache size: %lu bytes, files: %lu", (unsigned long)cacheSize, (unsigned long)fileCount);

// Calculate cache size asynchronously (more accurate)
[imageCache calculateSizeWithCompletionBlock:^(NSUInteger fileCount, NSUInteger totalSize) {
    NSLog(@"Total cache: %lu files, %.2f MB",
          (unsigned long)fileCount,
          totalSize / 1024.0 / 1024.0);
}];
```

### 4. Download Manager Configuration

```objective-c
#import <LWSDWebImage/SDWebImageDownloader.h>

SDWebImageDownloader *downloader = [SDWebImageDownloader sharedDownloader];

// Concurrency and timeout
downloader.maxConcurrentDownloads = 6;  // Default is 6
downloader.downloadTimeout = 15.0;  // Default is 15 seconds

// Execution order
downloader.executionOrder = SDWebImageDownloaderFIFOExecutionOrder;  // or LIFOExecutionOrder

// HTTP headers
[downloader setValue:@"application/json" forHTTPHeaderField:@"Accept"];
[downloader setValue:@"MyApp/1.0" forHTTPHeaderField:@"User-Agent"];

// Authentication
downloader.username = @"username";
downloader.password = @"password";

// Image decompression
downloader.shouldDecompressImages = YES;
```

### 5. Independent Downloader Usage

Use the downloader directly without caching:

```objective-c
SDWebImageDownloader *downloader = [SDWebImageDownloader sharedDownloader];

SDWebImageDownloadToken *token = [downloader downloadImageWithURL:imageURL
                                                           options:SDWebImageDownloaderHighPriority
                                                          progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL *targetURL) {
                                                              float progress = (float)receivedSize / expectedSize;
                                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                                  progressBar.progress = progress;
                                                              });
                                                          }
                                                         completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                                                             if (image && finished) {
                                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                                     imageView.image = image;
                                                                 });
                                                             }
                                                         }];

// Cancel download if needed
[downloader cancel:token];

// Suspend/resume all downloads
[downloader setSuspended:YES];
[downloader setSuspended:NO];

// Cancel all downloads
[downloader cancelAllDownloads];
```

### 6. Multiple Cache Namespaces

Create separate caches for different content types:

```objective-c
// Create specialized caches
SDImageCache *avatarCache = [[SDImageCache alloc] initWithNamespace:@"avatar"];
SDImageCache *productCache = [[SDImageCache alloc] initWithNamespace:@"product"];
SDImageCache *thumbnailCache = [[SDImageCache alloc] initWithNamespace:@"thumbnail"];

// Configure each cache independently
avatarCache.config.maxCacheAge = 60 * 60 * 24 * 30;  // 30 days for avatars
productCache.config.maxCacheSize = 1024 * 1024 * 200;  // 200 MB for products
thumbnailCache.config.shouldDecompressImages = NO;  // Don't decompress thumbnails

// Use specific cache
[avatarCache storeImage:userAvatar forKey:@"user123" completion:^{
    NSLog(@"Avatar cached");
}];
```

### 7. Checking Cache Status

```objective-c
SDWebImageManager *manager = [SDWebImageManager sharedManager];

// Check if image exists in cache
[manager cachedImageExistsForURL:imageURL
                      completion:^(BOOL isInCache) {
    if (isInCache) {
        NSLog(@"Image is already cached");
    }
}];

// Check only disk cache
[manager diskImageExistsForURL:imageURL
                    completion:^(BOOL isInCache) {
    if (isInCache) {
        NSLog(@"Image is in disk cache");
    }
}];

// Query cache with detailed information
[[SDImageCache sharedImageCache] queryCacheOperationForKey:cacheKey
                                                      done:^(UIImage *image, NSData *data, SDImageCacheType cacheType) {
    if (image) {
        switch (cacheType) {
            case SDImageCacheTypeNone:
                NSLog(@"Image not in cache");
                break;
            case SDImageCacheTypeMemory:
                NSLog(@"Image loaded from memory cache");
                break;
            case SDImageCacheTypeDisk:
                NSLog(@"Image loaded from disk cache");
                break;
        }
    }
}];
```

### 8. Cache Cleaning and Maintenance

```objective-c
SDImageCache *cache = [SDImageCache sharedImageCache];

// Clear memory cache (call on memory warning)
[cache clearMemory];

// Clear all disk cache
[cache clearDiskOnCompletion:^{
    NSLog(@"All disk cache cleared");
}];

// Remove specific image
[cache removeImageForKey:@"image_key" withCompletion:^{
    NSLog(@"Image removed");
}];

// Remove image from disk only
[cache removeImageForKey:@"image_key" fromDisk:YES withCompletion:^{
    NSLog(@"Image removed from disk");
}];

// Clean expired cache files (called automatically in background)
[cache deleteOldFilesWithCompletionBlock:^{
    NSLog(@"Old files cleaned");
}];

// Recommended: Call these in AppDelegate
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    [[SDImageCache sharedImageCache] clearMemory];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[SDImageCache sharedImageCache] deleteOldFilesWithCompletionBlock:nil];
}
```

## API Reference

### SDWebImageManager

The central manager class that coordinates caching and downloading.

```objective-c
@interface SDWebImageManager : NSObject

// Singleton instance
+ (instancetype)sharedManager;

// Load image with full control
- (id<SDWebImageOperation>)loadImageWithURL:(NSURL *)url
                                    options:(SDWebImageOptions)options
                                   progress:(SDWebImageDownloaderProgressBlock)progressBlock
                                  completed:(SDInternalCompletionBlock)completedBlock;

// Save image to cache
- (void)saveImageToCache:(UIImage *)image forURL:(NSURL *)url;

// Cancel operations
- (void)cancelAll;
- (BOOL)isRunning;

// Cache key management
- (NSString *)cacheKeyForURL:(NSURL *)url;
- (void)setCacheKeyFilter:(SDWebImageCacheKeyFilterBlock)filter;

// Check cache status
- (void)cachedImageExistsForURL:(NSURL *)url
                     completion:(SDWebImageCheckCacheCompletionBlock)completionBlock;
- (void)diskImageExistsForURL:(NSURL *)url
                   completion:(SDWebImageCheckCacheCompletionBlock)completionBlock;

// Properties
@property (strong, nonatomic, readonly) SDImageCache *imageCache;
@property (strong, nonatomic, readonly) SDWebImageDownloader *imageDownloader;
@property (weak, nonatomic) id<SDWebImageManagerDelegate> delegate;

@end
```

### SDImageCache

Manages image caching to memory and disk.

```objective-c
@interface SDImageCache : NSObject

// Singleton instance
+ (instancetype)sharedImageCache;

// Initialize with custom namespace
- (instancetype)initWithNamespace:(NSString *)ns;

// Store images
- (void)storeImage:(UIImage *)image
            forKey:(NSString *)key
        completion:(SDWebImageNoParamsBlock)completionBlock;

- (void)storeImage:(UIImage *)image
         imageData:(NSData *)imageData
            forKey:(NSString *)key
            toDisk:(BOOL)toDisk
        completion:(SDWebImageNoParamsBlock)completionBlock;

// Query cache
- (NSOperation *)queryCacheOperationForKey:(NSString *)key
                                      done:(SDCacheQueryCompletedBlock)doneBlock;

// Synchronous retrieval
- (UIImage *)imageFromMemoryCacheForKey:(NSString *)key;
- (UIImage *)imageFromDiskCacheForKey:(NSString *)key;

// Remove images
- (void)removeImageForKey:(NSString *)key withCompletion:(SDWebImageNoParamsBlock)completion;
- (void)removeImageForKey:(NSString *)key fromDisk:(BOOL)fromDisk withCompletion:(SDWebImageNoParamsBlock)completion;

// Clear cache
- (void)clearMemory;
- (void)clearDiskOnCompletion:(SDWebImageNoParamsBlock)completion;

// Cache maintenance
- (void)deleteOldFilesWithCompletionBlock:(SDWebImageNoParamsBlock)completionBlock;

// Cache info
- (NSUInteger)getSize;
- (NSUInteger)getDiskCount;
- (void)calculateSizeWithCompletionBlock:(SDWebImageCalculateSizeBlock)completionBlock;

// Configuration
@property (nonatomic, strong, readonly) SDImageCacheConfig *config;

@end
```

### SDWebImageDownloader

Handles asynchronous image downloading.

```objective-c
@interface SDWebImageDownloader : NSObject

// Singleton instance
+ (instancetype)sharedDownloader;

// Download image
- (SDWebImageDownloadToken *)downloadImageWithURL:(NSURL *)url
                                          options:(SDWebImageDownloaderOptions)options
                                         progress:(SDWebImageDownloaderProgressBlock)progressBlock
                                        completed:(SDWebImageDownloaderCompletedBlock)completedBlock;

// Cancel operations
- (void)cancel:(SDWebImageDownloadToken *)token;
- (void)cancelAllDownloads;

// Control downloads
- (void)setSuspended:(BOOL)suspended;

// HTTP configuration
- (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field;
- (NSString *)valueForHTTPHeaderField:(NSString *)field;

// Properties
@property (assign, nonatomic) NSInteger maxConcurrentDownloads;
@property (assign, nonatomic) NSTimeInterval downloadTimeout;
@property (assign, nonatomic) SDWebImageDownloaderExecutionOrder executionOrder;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *password;
@property (assign, nonatomic) BOOL shouldDecompressImages;

@end
```

### SDWebImagePrefetcher

Batch prefetch images for improved performance.

```objective-c
@interface SDWebImagePrefetcher : NSObject

// Singleton instance
+ (instancetype)sharedImagePrefetcher;

// Prefetch images
- (void)prefetchURLs:(NSArray<NSURL *> *)urls;

- (void)prefetchURLs:(NSArray<NSURL *> *)urls
            progress:(SDWebImagePrefetcherProgressBlock)progressBlock
           completed:(SDWebImagePrefetcherCompletionBlock)completionBlock;

// Cancel prefetch
- (void)cancelPrefetching;

// Properties
@property (strong, nonatomic, readonly) SDWebImageManager *manager;
@property (assign, nonatomic) NSUInteger maxConcurrentDownloads;
@property (assign, nonatomic) SDWebImageOptions options;

@end
```

### Image Loading Options (SDWebImageOptions)

```objective-c
typedef NS_OPTIONS(NSUInteger, SDWebImageOptions) {
    SDWebImageRetryFailed = 1 << 0,              // Retry failed URLs
    SDWebImageLowPriority = 1 << 1,              // Low priority (no download during UI scrolls)
    SDWebImageCacheMemoryOnly = 1 << 2,          // Memory cache only, no disk
    SDWebImageProgressiveDownload = 1 << 3,      // Progressive download (show incrementally)
    SDWebImageRefreshCached = 1 << 4,            // Refresh cached image from network
    SDWebImageContinueInBackground = 1 << 5,     // Continue download in background
    SDWebImageHandleCookies = 1 << 6,            // Handle cookies from NSHTTPCookieStore
    SDWebImageAllowInvalidSSLCertificates = 1 << 7,  // Allow invalid SSL certificates
    SDWebImageHighPriority = 1 << 8,             // High priority download
    SDWebImageDelayPlaceholder = 1 << 9,         // Delay setting placeholder
    SDWebImageTransformAnimatedImage = 1 << 10,  // Transform animated images
    SDWebImageAvoidAutoSetImage = 1 << 11,       // Manual image setting in completion
    SDWebImageScaleDownLargeImages = 1 << 12     // Scale down large images
};
```

### Cache Types

```objective-c
typedef NS_ENUM(NSInteger, SDImageCacheType) {
    SDImageCacheTypeNone,    // Image from network
    SDImageCacheTypeDisk,    // Image from disk cache
    SDImageCacheTypeMemory   // Image from memory cache
};
```

## Best Practices

### 1. Memory Management

```objective-c
// In AppDelegate
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    // Clear memory cache to free up memory
    [[SDImageCache sharedImageCache] clearMemory];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Clean up expired cache files in background
    UIBackgroundTaskIdentifier bgTask = [application beginBackgroundTaskWithExpirationHandler:^{}];
    [[SDImageCache sharedImageCache] deleteOldFilesWithCompletionBlock:^{
        [application endBackgroundTask:bgTask];
    }];
}
```

### 2. Optimize for Lists

```objective-c
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Use low priority for better scrolling performance
    [cell.imageView sd_setImageWithURL:imageURL
                      placeholderImage:placeholder
                               options:SDWebImageLowPriority];
    return cell;
}

// Prefetch next page while user is viewing current page
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.items.count - 5) {
        // User is near the end, prefetch next page
        [[SDWebImagePrefetcher sharedImagePrefetcher] prefetchURLs:nextPageImageURLs];
    }
}
```

### 3. Handle Network Conditions

```objective-c
#import <SystemConfiguration/SystemConfiguration.h>

// Check network before downloading
if ([self isConnectedToNetwork]) {
    [imageView sd_setImageWithURL:imageURL
                 placeholderImage:placeholder
                          options:SDWebImageRetryFailed];
} else {
    // Load from cache only
    NSString *key = [[SDWebImageManager sharedManager] cacheKeyForURL:imageURL];
    UIImage *cachedImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:key];
    imageView.image = cachedImage ?: placeholder;
}
```

### 4. Secure Image Loading

```objective-c
// For production: Always use HTTPS
NSURL *secureURL = [NSURL URLWithString:@"https://example.com/image.jpg"];

// For development/testing only: Allow invalid SSL certificates
[imageView sd_setImageWithURL:devURL
             placeholderImage:placeholder
                      options:SDWebImageAllowInvalidSSLCertificates];
```

### 5. Custom Cache Strategies

```objective-c
// Implement custom cache key filtering for dynamic URLs
[[SDWebImageManager sharedManager] setCacheKeyFilter:^NSString *(NSURL *url) {
    // Remove query parameters and fragments for consistent caching
    NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
    components.query = nil;
    components.fragment = nil;
    return components.URL.absoluteString;
}];

// Example: URLs with different timestamps use same cache
// http://example.com/image.jpg?t=123456 -> http://example.com/image.jpg
// http://example.com/image.jpg?t=789012 -> http://example.com/image.jpg
```

## Example Project

To run the example project, clone the repository and install dependencies:

```bash
git clone https://gitlab.com/ioslibraries1/lwsdwebimage.git
cd LWSDWebImage/Example
pod install
open LWSDWebImage.xcworkspace
```

The example project demonstrates:
- Basic image loading in UIImageView and UIButton
- List view with efficient cell reuse
- Progressive image loading
- GIF animation support
- Cache management
- Download progress tracking
- Custom image transformations

## FAQ

### Q: Images not displaying?

**A:** Check these common issues:
- Verify URL is correct and accessible
- Ensure your Info.plist allows HTTP connections if not using HTTPS (add `NSAppTransportSecurity`)
- Check console for error messages
- Verify network connectivity

```xml
<!-- Info.plist for HTTP support (use HTTPS in production) -->
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

### Q: High memory usage?

**A:** Try these solutions:

```objective-c
// Disable memory caching
[[SDImageCache sharedImageCache] config].shouldCacheImagesInMemory = NO;

// Or use cache memory only option
[imageView sd_setImageWithURL:url
             placeholderImage:placeholder
                      options:SDWebImageCacheMemoryOnly];

// Set maximum cache size
[[SDImageCache sharedImageCache] config].maxCacheSize = 1024 * 1024 * 50; // 50 MB
```

### Q: How to force refresh an image?

**A:** Use the `SDWebImageRefreshCached` option:

```objective-c
[imageView sd_setImageWithURL:url
             placeholderImage:placeholder
                      options:SDWebImageRefreshCached];
```

### Q: Can I load local images?

**A:** Yes, use file URLs:

```objective-c
NSString *localPath = [[NSBundle mainBundle] pathForResource:@"image" ofType:@"jpg"];
NSURL *localURL = [NSURL fileURLWithPath:localPath];
[imageView sd_setImageWithURL:localURL];
```

### Q: How to handle authentication?

**A:** Set credentials on the downloader:

```objective-c
SDWebImageDownloader *downloader = [SDWebImageDownloader sharedDownloader];
downloader.username = @"myusername";
downloader.password = @"mypassword";

// Or use custom HTTP headers
[downloader setValue:authToken forHTTPHeaderField:@"Authorization"];
```

### Q: Thread safety?

**A:** All SDWebImage APIs are thread-safe. You can call them from any thread, and completion blocks are called on the main thread by default.

### Q: How to cancel loading?

**A:** Cancellation is automatic when setting a new URL, or manual:

```objective-c
// Automatic cancellation when setting new URL
[imageView sd_setImageWithURL:newURL];

// Manual cancellation
[imageView sd_cancelCurrentImageLoad];

// Cancel specific operation
id<SDWebImageOperation> operation = [manager loadImageWithURL:url ...];
[operation cancel];
```

## Performance Tips

1. **Optimize cache size**: Set appropriate `maxCacheSize` and `maxCacheAge` based on your app's needs
2. **Use image format wisely**: WebP provides better compression than JPEG/PNG
3. **Prefetch strategically**: Use `SDWebImagePrefetcher` to preload images that will be needed soon
4. **Monitor cache**: Regularly check cache size and clean up when necessary
5. **Use CDN**: Host images on a CDN for faster downloads
6. **Scale images server-side**: Download appropriately sized images rather than full resolution
7. **Lazy loading**: Only load images when they're about to be displayed

## Thread Safety

- All public APIs are thread-safe
- Methods can be called from any thread
- Completion blocks execute on the main thread (unless specified otherwise)
- Progress blocks execute on background threads
- Image transformations run on background threads

## Migration Guide

If migrating from direct SDWebImage usage to LWSDWebImage:

1. Replace import statements:
   ```objective-c
   // Old
   #import <SDWebImage/UIImageView+WebCache.h>

   // New
   #import <LWSDWebImage/UIImageView+WebCache.h>
   ```

2. All existing SDWebImage code remains compatible
3. No API changes required - LWSDWebImage is a wrapper maintaining full compatibility

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## Author

**luowei**
- Email: luowei@wodedata.com
- Project: https://gitlab.com/ioslibraries1/lwsdwebimage

## Acknowledgments

This project is built on top of [SDWebImage](https://github.com/SDWebImage/SDWebImage). Special thanks to the SDWebImage team for their excellent work on the underlying image loading framework.

## License

LWSDWebImage is available under the MIT license. See the [LICENSE](LICENSE) file for more info.

---

For issues, questions, or suggestions, please open an issue on the [project repository](https://gitlab.com/ioslibraries1/lwsdwebimage).
