# LCInfiniteScrollView
An infinite scroll control implemented with two views, supporting custom reuse of views.

## Requirements

- **iOS 8.0+**

> Programming in Swift? Try [LCCycleBanner](https://github.com/iLiuChang/LCCycleBanner) for a more conventional set of APIs.

## Features

- Supports infinite scrolling.
- Reuse with two views.
- Support for custom reuse views.

## Usage

### Init

```objective-c
LCInfiniteScrollView *v = [[LCInfiniteScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 300)];
v.backgroundColor = UIColor.brownColor;
v.delegate = self;
v.autoScroll = YES;
[self.view addSubview:v];
```

### Custom reuse view

```objective-c
- (UIView *)reusableViewInInfiniteScrollView:(LCInfiniteScrollView *)infiniteScrollView {
    UILabel *label = [UILabel new];
    label.font = [UIFont boldSystemFontOfSize:30];
    label.textAlignment = NSTextAlignmentCenter;
    return label;
}

- (void)infiniteScrollView:(LCInfiniteScrollView *)infiniteScrollView reusableView:(UIView *)reusableView atIndex:(NSInteger)index {
    UILabel *label = (UILabel *)reusableView;
    label.text = @(index).stringValue;
    label.backgroundColor = (UIColor *)self.colors[index];
}
```

## Installation

### CocoaPods

To integrate LCInfiniteScrollView into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
pod 'LCInfiniteScrollView'
```

### Manually

1. Download all the files in the LCInfiniteScrollView subdirectory.
2. Add the source files to your Xcode project.

3. import `LCInfiniteScrollView.h`.

## License

LCInfiniteScrollView is provided under the MIT license. See LICENSE file for details.