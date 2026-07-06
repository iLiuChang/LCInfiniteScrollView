# LoopScroll

![Swift](https://img.shields.io/badge/Swift-5.0%2B-orange.svg)
![Platform](https://img.shields.io/badge/Platform-iOS%2011.0%2B-lightgrey.svg)
![Version](https://img.shields.io/badge/Version-1.0.0-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)
![SPM](https://img.shields.io/badge/SPM-supported-brightgreen.svg)
![CocoaPods](https://img.shields.io/badge/CocoaPods-supported-blueviolet.svg)

## Overview

An infinitely looping scroll control for iOS, built on `UICollectionView`. Provides two components:

- **LoopCollectionView** — flexible infinite scrolling with custom item sizing and spacing
- **LoopPagingView** — page-based infinite scrolling with configurable auto-scroll

## Features

- **Infinite Scrolling** — seamlessly loops through items in both directions using boundary-element padding
- **Custom Item Size & Spacing** — configure `itemSize` and `itemSpacing` for non-full-width items, or leave default for full-page paging
- **Horizontal & Vertical** — switch scroll direction with a single property
- **Auto Scroll** — configurable timer-based automatic paging (LoopPagingView)
- **DataSource & Delegate** — familiar `UICollectionView`-style protocols
- **Objective-C Compatible** — all public APIs are `@objc` exposed

## Requirements

- iOS 11.0+
- Swift 5.0+

## Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/iLiuChang/LoopScroll.git", from: "1.0.0")
]
```

### CocoaPods

```ruby
pod 'LoopScroll'
```

## Usage

### LoopCollectionView — Infinite Scrolling

```swift
import LoopScroll

let loopView = LoopCollectionView()
loopView.scrollDirection = .horizontal        // or .vertical
loopView.itemSize = 200                       // custom item width/height, 0 for full-page
loopView.itemSpacing = 10                     // spacing between items
loopView.dataSource = self
loopView.delegate = self
loopView.register(MyCell.self, forCellWithReuseIdentifier: "Cell")
```

### LoopPagingView — Page-Based with Auto Scroll

```swift
import LoopScroll

let pagingView = LoopPagingView()
pagingView.scrollDirection = .horizontal
pagingView.autoScrollTimeInterval = 3.0       // 0 to disable auto-scroll
pagingView.disableLoopForSingleItem = true    // disable looping when only 1 item
pagingView.dataSource = self
pagingView.delegate = self
pagingView.register(MyCell.self, forCellWithReuseIdentifier: "Cell")
```

### DataSource

```swift
extension ViewController: LoopCollectionViewDataSource {

    func numberOfItems(in loopCollectionView: LoopCollectionView) -> Int {
        return items.count
    }

    func loopCollectionView(_ loopCollectionView: LoopCollectionView, cellForItemAt index: Int) -> UICollectionViewCell {
        let cell = loopCollectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: index)
        // configure cell
        return cell
    }
}
```

### Delegate

```swift
extension ViewController: LoopCollectionViewDelegate {

    func loopCollectionView(_ loopCollectionView: LoopCollectionView, didSelectItemAt index: Int) {
        print("Selected item at index: \(index)")
    }

    func loopCollectionView(_ loopCollectionView: LoopCollectionView, willDisplay cell: UICollectionViewCell, forItemAt index: Int) {
        pageControl.currentPage = index
    }
}
```

## API Reference

### LoopCollectionView

| Property / Method | Description |
|---|---|
| `scrollDirection` | `.horizontal` or `.vertical` |
| `itemSize` | Custom item size along scroll axis. `0` uses full bounds (page mode). |
| `itemSpacing` | Spacing between adjacent items. |
| `panGestureRecognizer` | The underlying `UIPanGestureRecognizer`. |
| `reloadData()` | Reloads all items. |
| `scrollToItem(at:animated:)` | Scrolls to a specific item. |
| `selectItem(at:animated:)` | Programmatically selects an item. |
| `deselectItem(at:animated:)` | Programmatically deselects an item. |
| `cellForItem(at:)` | Returns the visible cell at the given index. |
| `index(for:)` | Returns the logical index for a given cell. |
| `register(_:forCellWithReuseIdentifier:)` | Registers a cell class or nib. |

### LoopPagingView (extends LoopCollectionView)

| Property / Method | Description |
|---|---|
| `autoScrollTimeInterval` | Auto-scroll interval in seconds. `0` disables auto-scroll. |
| `disableLoopForSingleItem` | When `true`, a single item won't loop and scrolling is disabled. |
| `startTimer()` | Manually starts the auto-scroll timer. |
| `cancelTimer()` | Manually stops the auto-scroll timer. |

> Note: `itemSize` and `itemSpacing` are locked to `0` in `LoopPagingView` — it always uses full-page sizing.

### Delegate Methods

| Method | Description |
|---|---|
| `shouldHighlightItemAt` | Whether the item should highlight on touch. |
| `didHighlightItemAt` | Called when an item is highlighted. |
| `shouldSelectItemAt` | Whether the item should be selected on tap. |
| `didSelectItemAt` | Called when the user taps an item. |
| `willDisplay:forItemAt` | Called before a cell becomes visible. |
| `didEndDisplaying:forItemAt` | Called after a cell scrolls off screen. |
| `willBeginDragging` | Called when the user starts dragging. |
| `willEndDragging` | Called when the user stops dragging. |
| `didScroll` | Called on every scroll event. |
| `didEndScrollAnimation` | Called when a programmatic scroll animation finishes. |
| `didEndDecelerating` | Called when scroll deceleration completes. |
| `didEndDragging:willDecelerate` | Called when dragging ends with deceleration info. |

## Architecture

`LoopCollectionView` is a `UIView` subclass that internally manages a `UICollectionView` with `UICollectionViewFlowLayout`. It pads items with boundary elements at both ends and swaps `contentOffset` when the user scrolls past the boundaries, creating a seamless infinite loop. When `itemSize` is `0`, it uses full bounds sizing with paging enabled for page-aligned snapping.

`LoopPagingView` extends `LoopCollectionView`, locking item size to full-page and adding a `Timer`-based auto-scroll mechanism that pauses during user interaction and resumes on release.

## License

MIT License. See [LICENSE](LICENSE) for details.
