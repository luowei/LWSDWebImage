# Graph Report - /Users/luowei/projects/libs/LWSDWebImage  (2026-05-04)

## Corpus Check
- Corpus is ~33,192 words - fits in a single context window. You may not need a graph.

## Summary
- 407 nodes · 422 edges · 29 communities detected
- Extraction: 99% EXTRACTED · 1% INFERRED · 0% AMBIGUOUS · INFERRED: 3 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- [[_COMMUNITY_Community 0|Community 0]]
- [[_COMMUNITY_Community 1|Community 1]]
- [[_COMMUNITY_Community 2|Community 2]]
- [[_COMMUNITY_Community 3|Community 3]]
- [[_COMMUNITY_Community 4|Community 4]]
- [[_COMMUNITY_Community 5|Community 5]]
- [[_COMMUNITY_Community 6|Community 6]]
- [[_COMMUNITY_Community 7|Community 7]]
- [[_COMMUNITY_Community 8|Community 8]]
- [[_COMMUNITY_Community 9|Community 9]]
- [[_COMMUNITY_Community 10|Community 10]]
- [[_COMMUNITY_Community 11|Community 11]]
- [[_COMMUNITY_Community 12|Community 12]]
- [[_COMMUNITY_Community 13|Community 13]]
- [[_COMMUNITY_Community 14|Community 14]]
- [[_COMMUNITY_Community 15|Community 15]]
- [[_COMMUNITY_Community 16|Community 16]]
- [[_COMMUNITY_Community 17|Community 17]]
- [[_COMMUNITY_Community 18|Community 18]]
- [[_COMMUNITY_Community 19|Community 19]]
- [[_COMMUNITY_Community 20|Community 20]]
- [[_COMMUNITY_Community 21|Community 21]]
- [[_COMMUNITY_Community 22|Community 22]]
- [[_COMMUNITY_Community 23|Community 23]]
- [[_COMMUNITY_Community 24|Community 24]]
- [[_COMMUNITY_Community 25|Community 25]]
- [[_COMMUNITY_Community 26|Community 26]]
- [[_COMMUNITY_Community 27|Community 27]]
- [[_COMMUNITY_Community 28|Community 28]]

## God Nodes (most connected - your core abstractions)
1. `SDImageCache` - 38 edges
2. `SDImageCache` - 24 edges
3. `SDWebImageDownloader` - 24 edges
4. `SDWebImageDownloaderOperation` - 24 edges
5. `UIButton` - 20 edges
6. `SDWebImageManager` - 14 edges
7. `UIView` - 14 edges
8. `SDWebImageManager` - 11 edges
9. `SDWebImagePrefetcher` - 11 edges
10. `UIImageView` - 11 edges

## Surprising Connections (you probably didn't know these)
- `SDWebImageManagerDelegate` --inherits--> `AnyObject`  [EXTRACTED]
  LWSDWebImage_swift/SwiftClasses/SDWebImageManager.swift →   _Bridges community 15 → community 8_
- `SDWebImagePrefetcher` --inherits--> `NSObject`  [EXTRACTED]
  LWSDWebImage_swift/SwiftClasses/SDWebImagePrefetcher.swift →   _Bridges community 15 → community 6_
- `SDWebImageCombinedOperation` --inherits--> `NSObject`  [EXTRACTED]
  LWSDWebImage_swift/SwiftClasses/SDWebImageManager.swift →   _Bridges community 6 → community 8_
- `SDImageCache` --inherits--> `NSObject`  [EXTRACTED]
  LWSDWebImage_swift/SwiftClasses/SDImageCache.swift →   _Bridges community 6 → community 1_
- `SDWebImageCombinedOperation` --inherits--> `NSObject`  [EXTRACTED]
  LWSDWebImage/Classes/SDWebImageManager.m →   _Bridges community 6 → community 7_

## Communities (51 total, 5 thin omitted)

### Community 0 - "Community 0"
Cohesion: 0.05
Nodes (41): AutoPurgeCache, -dealloc, -init, SDImageCache, -addReadOnlyCachePath, -backgroundDeleteOldFiles, -cachedFileNameForKey, -cachePathForKeyinPath (+33 more)

### Community 1 - "Community 1"
Cohesion: 0.13
Nodes (3): SDImageCache, SDScaledImageForKey(), Data

### Community 2 - "Community 2"
Cohesion: 0.08
Nodes (25): SDWebImageDownloader, -addProgressCallbackcompletedBlockforURLcreateCallback, -cancel, -cancelAllDownloads, -currentDownloadCount, -dealloc, -downloadImageWithURLoptionsprogresscompleted, -init (+17 more)

### Community 3 - "Community 3"
Cohesion: 0.08
Nodes (24): SDWebImageDownloaderOperation, -addHandlersForProgresscompleted, -callbacksForKey, -callCompletionBlocksWithError, -callCompletionBlocksWithImageimageDataerrorfinished, -cancel, -cancelInternal, -dealloc (+16 more)

### Community 4 - "Community 4"
Cohesion: 0.11
Nodes (14): ObservableObject, Image, ImageLoadingState, failure, idle, loading, success, SDAsyncImage (+6 more)

### Community 5 - "Community 5"
Cohesion: 0.1
Nodes (20): UIButton, -imageURLStorage, -sd_cancelBackgroundImageLoadForState, -sd_cancelImageLoadForState, -sd_currentImageURL, -sd_imageURLForState, -sd_setBackgroundImageLoadOperationforState, -sd_setBackgroundImageWithURLforState (+12 more)

### Community 6 - "Community 6"
Cohesion: 0.13
Nodes (6): NSObject, Operation, SDImageCacheConfig, SDWebImageDownloader, SDWebImageDownloaderOperation, SDWebImageDownloadToken

### Community 7 - "Community 7"
Cohesion: 0.11
Nodes (17): SDWebImageCombinedOperation, -cancel, -setCancelBlock, SDWebImageManager, -cachedImageExistsForURLcompletion, -cacheKeyForURL, -callCompletionBlockForOperationcompletionerrorurl, -callCompletionBlockForOperationcompletionimagedataerrorcacheTypefinishedurl (+9 more)

### Community 8 - "Community 8"
Cohesion: 0.2
Nodes (4): SDWebImageOperation, SDWebImageCombinedOperation, SDWebImageManager, SDWebImageManagerDelegate

### Community 9 - "Community 9"
Cohesion: 0.14
Nodes (12): Int, OptionSet, SDImageCacheType, disk, memory, none, SDWebImageDownloaderExecutionOrder, fifo (+4 more)

### Community 10 - "Community 10"
Cohesion: 0.13
Nodes (14): UIView, -activityIndicator, -sd_addActivityIndicator, -sd_cancelCurrentImageLoad, -sd_getIndicatorStyle, -sd_imageURL, -sd_internalSetImageWithURLplaceholderImageoptionsoperationKeysetImageBlockprogresscompleted, -sd_removeActivityIndicator (+6 more)

### Community 12 - "Community 12"
Cohesion: 0.15
Nodes (10): SDImageFormat, gif, heic, heif, jpeg, png, tiff, undefined (+2 more)

### Community 13 - "Community 13"
Cohesion: 0.17
Nodes (11): SDWebImagePrefetcher, -cancelPrefetching, -init, -initWithImageManager, -maxConcurrentDownloads, -prefetchURLs, -prefetchURLsprogresscompleted, -reportStatus (+3 more)

### Community 14 - "Community 14"
Cohesion: 0.17
Nodes (11): UIImageView, -sd_cancelCurrentAnimationImagesLoad, -sd_setAnimationImagesWithURLs, -sd_setImageWithPreviousCachedImageWithURLplaceholderImageoptionsprogresscompleted, -sd_setImageWithURL, -sd_setImageWithURLcompleted, -sd_setImageWithURLplaceholderImage, -sd_setImageWithURLplaceholderImagecompleted (+3 more)

### Community 15 - "Community 15"
Cohesion: 0.29
Nodes (3): AnyObject, SDWebImagePrefetcher, SDWebImagePrefetcherDelegate

### Community 16 - "Community 16"
Cohesion: 0.22
Nodes (8): UIImage, -convertImageRGB, -createGIFWithImages2sizeloopCountdelayTimegifCachePath, -createGIFWithImagessizeloopCountdelayTimegifCachePath, -imagesFromGIFData, -isGIF, -scaleKeepAspectToSize, -sd_animatedGIFWithData

### Community 17 - "Community 17"
Cohesion: 0.25
Nodes (7): LWAppDelegate, -applicationDidBecomeActive, -applicationDidEnterBackground, -applicationdidFinishLaunchingWithOptions, -applicationWillEnterForeground, -applicationWillResignActive, -applicationWillTerminate

### Community 19 - "Community 19"
Cohesion: 0.29
Nodes (6): UIImage, -colorSpaceForImageRef, -decodedAndScaledDownImageWithImage, -decodedImageWithImage, -shouldDecodeImage, -shouldScaleDownImage

### Community 20 - "Community 20"
Cohesion: 0.29
Nodes (6): UIImageView, -sd_setHighlightedImageWithURL, -sd_setHighlightedImageWithURLcompleted, -sd_setHighlightedImageWithURLoptions, -sd_setHighlightedImageWithURLoptionscompleted, -sd_setHighlightedImageWithURLoptionsprogresscompleted

### Community 21 - "Community 21"
Cohesion: 0.29
Nodes (6): UIImage, -sd_exifOrientationToiOSOrientation, -sd_imageData, -sd_imageDataAsFormat, -sd_imageOrientationFromImageData, -sd_imageWithData

### Community 22 - "Community 22"
Cohesion: 0.33
Nodes (5): UIView, -operationDictionary, -sd_cancelImageLoadOperationWithKey, -sd_removeImageLoadOperationWithKey, -sd_setImageLoadOperationforKey

### Community 23 - "Community 23"
Cohesion: 0.4
Nodes (4): Tests, -setUp, -tearDown, -testExample

### Community 24 - "Community 24"
Cohesion: 0.4
Nodes (4): NSImage, -CGImage, -images, -isGIF

### Community 25 - "Community 25"
Cohesion: 0.5
Nodes (3): LWViewController, -didReceiveMemoryWarning, -viewDidLoad

## Knowledge Gaps
- **214 isolated node(s):** `-setUp`, `-tearDown`, `-testExample`, `-applicationdidFinishLaunchingWithOptions`, `-applicationWillResignActive` (+209 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **5 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `SDImageCache` connect `Community 1` to `Community 6`?**
  _High betweenness centrality (0.052) - this node is a cross-community bridge._
- **Why does `SDWebImageCombinedOperation` connect `Community 7` to `Community 8`, `Community 6`?**
  _High betweenness centrality (0.022) - this node is a cross-community bridge._
- **What connects `-setUp`, `-tearDown`, `-testExample` to the rest of the system?**
  _214 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Community 0` be split into smaller, more focused modules?**
  _Cohesion score 0.05 - nodes in this community are weakly interconnected._
- **Should `Community 1` be split into smaller, more focused modules?**
  _Cohesion score 0.13 - nodes in this community are weakly interconnected._
- **Should `Community 2` be split into smaller, more focused modules?**
  _Cohesion score 0.08 - nodes in this community are weakly interconnected._
- **Should `Community 3` be split into smaller, more focused modules?**
  _Cohesion score 0.08 - nodes in this community are weakly interconnected._