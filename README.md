# LCInfiniteScrollView
An infinite scroll control implemented with two views, supporting custom reuse of views.

## Requirements

-  **Objective-C**

  - **iOS 8.0+**

    

- **Swift**
  - **iOS 9.0+**
  - **Swift 4.0+**

## Features

- Supports infinite scrolling.
- Reuse with two views.
- Support for custom reuse views.

## Usage

### Init

- **Objective-C**

```objective-c
LCInfiniteScrollView *v = [[LCInfiniteScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 300)];
v.backgroundColor = UIColor.brownColor;
v.delegate = self;
v.autoScroll = YES;
[self.view addSubview:v];
```

- **Swift**

```swift
let banner = LCInfiniteScrollView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 200))
banner.delegate = self
banner.autoScroll = true
self.view.addSubview(banner)
```

### Custom reuse view

- **Objective-C**

```objective-c
- (UIView *)reusableViewInInfiniteScrollView:(LCInfiniteScrollView *)infiniteScrollView {
    UILabel *label = [UILabel new];
    label.font = [UIFont boldSystemFontOfSize:30];
    label.textAlignment = NSTextAlignmentCenter;
    return label;
}

- (void)infiniteScrollView:(LCInfiniteScrollView *)infiniteScrollView displayReusableView:(UIView *)reusableView atIndex:(NSInteger)index {
    UILabel *label = (UILabel *)reusableView;
    label.text = @(index).stringValue;
    label.backgroundColor = (UIColor *)self.colors[index];
}
```

- **Swift**

```swift
func infiniteScrollView(_ infiniteScrollView: LCInfiniteScrollView, displayReusableView view: UIView, forIndex index: Int) {
    view.backgroundColor = colors[index]
}

func reusableView(in infiniteScrollView: LCInfiniteScrollView) -> UIView {
    return UIView()
}
```

## Installation

### CocoaPods

To integrate LCInfiniteScrollView into your Xcode project using CocoaPods, specify it in your `Podfile`:

- **Objective-C**

```ruby
pod 'LCInfiniteScrollView'
```

- **Swift**

```ruby
pod 'SwiftInfiniteScrollView'
```

### Manual

- **Objective-C**

1. Download everything in the LCInfiniteScrollView folder;
2. Add (drag and drop) the source files in LCInfiniteScrollView to your project.
3. import `LCInfiniteScrollView.h`.

- **Swift**

1. Download everything in the LCInfiniteScrollView folder;
2. Add (drag and drop) the source files in SwiftInfiniteScrollView to your project.

## License

LCInfiniteScrollView is provided under the MIT license. See LICENSE file for details.