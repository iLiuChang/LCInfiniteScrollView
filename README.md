# LCInfiniteScrollView

![Swift](https://img.shields.io/badge/Swift-5.0%2B-orange.svg)
![Platform](https://img.shields.io/badge/Platform-iOS%2011.0%2B-lightgrey.svg)
![Version](https://img.shields.io/badge/Version-2.0.0-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)
![SPM](https://img.shields.io/badge/SPM-supported-brightgreen.svg)
![CocoaPods](https://img.shields.io/badge/CocoaPods-supported-blueviolet.svg)

An infinitely scrolling pagination control for iOS, built on top of `UICollectionView`. Supports horizontal and vertical scroll directions, auto-scrolling, and a familiar delegate/dataSource API.

## Features

- **Infinite Scrolling** — seamlessly loops through items in both directions
- **Horizontal & Vertical** — switch scroll direction with a single property
- **Auto Scroll** — configurable timer-based automatic paging
- **Paging Snap** — custom layout ensures precise page-aligned snapping with velocity-aware targeting
- **DataSource & Delegate** — familiar `UICollectionView`-style protocols
- **Objective-C Compatible** — all public APIs are `@objc` exposed
- **Lightweight** — no external dependencies, ~500 lines of Swift

## Requirements

- iOS 11.0+
- Swift 5.0+

## Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/iLiuChang/LCInfiniteScrollView.git", from: "2.0.0")
]
```

### CocoaPods

```ruby
pod 'LCInfiniteScrollView', '~> 2.0.0'
```

## Usage

### Basic Setup

```swift
import LCInfiniteScrollView

let scrollView = LCInfiniteScrollView()
scrollView.scrollDirection = .horizontal        // or .vertical
scrollView.autoScrollTimeInterval = 3.0         // 0 to disable auto-scroll
scrollView.interitemSpacing = 10                // spacing between pages
scrollView.dataSource = self
scrollView.delegate = self
scrollView.register(MyCell.self, forCellWithReuseIdentifier: "Cell")
```

### DataSource

```swift
extension ViewController: LCInfiniteScrollViewDataSource {

    func numberOfItems(in infiniteScrollView: LCInfiniteScrollView) -> Int {
        return items.count
    }

    func infiniteScrollView(_ infiniteScrollView: LCInfiniteScrollView, cellForItemAt index: Int) -> UICollectionViewCell {
        let cell = infiniteScrollView.dequeueReusableCell(withReuseIdentifier: "Cell", at: index)
        // configure cell
        return cell
    }
}
```

### Delegate

```swift
extension ViewController: LCInfiniteScrollViewDelegate {

    func infiniteScrollView(_ infiniteScrollView: LCInfiniteScrollView, didSelectItemAt index: Int) {
        print("Selected item at index: \(index)")
    }

    func infiniteScrollView(_ infiniteScrollView: LCInfiniteScrollView, willDisplay cell: UICollectionViewCell, forItemAt index: Int) {
        pageControl.currentPage = index
    }
}
```

### API Reference

| Property / Method | Description |
|---|---|
| `scrollDirection` | `.horizontal` or `.vertical` |
| `autoScrollTimeInterval` | Auto-scroll interval in seconds. `0` disables auto-scroll. |
| `interitemSpacing` | Spacing between adjacent items. |
| `disableInfiniteLoopForSingleItem` | When `true`, a single item won't loop infinitely. |
| `currentIndex` | The currently visible page index (KVO observable). |
| `scrollOffset` | Normalized scroll offset modulo item count. |
| `reloadData()` | Reloads all items. |
| `selectItem(at:animated:)` | Programmatically selects an item. |
| `scrollToItem(at:animated:)` | Scrolls to a specific item. |
| `startTimer()` / `cancelTimer()` | Manually control the auto-scroll timer. |

### Delegate Methods

| Method | Description |
|---|---|
| `didSelectItemAt` | Called when the user taps an item. |
| `willDisplay:forItemAt` | Called before a cell becomes visible. |
| `didEndDisplaying:forItemAt` | Called after a cell scrolls off screen. |
| `willBeginDragging` | Called when the user starts dragging. |
| `willEndDragging:targetIndex` | Called when dragging ends, before deceleration. |
| `didScroll` | Called on every scroll event. |
| `didEndScrollAnimation` | Called when a programmatic scroll animation finishes. |
| `didEndDecelerating` | Called when scroll deceleration completes. |

## Architecture

`LCInfiniteScrollView` is a `UIView` subclass that internally manages a `UICollectionView` with a custom `LCInfiniteScrollLayout`. The layout multiplies items across many virtual sections to simulate infinite scrolling, and provides velocity-based target content offset for precise page snapping.

## License

MIT License. See [LICENSE](LICENSE) for details.