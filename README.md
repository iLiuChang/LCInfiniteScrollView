# LCInfiniteScrollView
An infinite scroll control implemented with two views, supporting custom reuse of views.

# Requirements

- **iOS 8.0+**

# Features

- Supports infinite scrolling.
- Reuse with two views.
- Support for custom reuse views.

# Usage

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

# Installation

### CocoaPods

1. Update cocoapods to the latest version.
2. Add `pod 'LCInfiniteScrollView'` to your Podfile.
3. Run `pod install` or `pod update`.
4. Import <LCInfiniteScrollView/LCInfiniteScrollView.h>.

### Manually

1. Download all the files in the YYImage subdirectory.
2. Add the source files to your Xcode project.

3. import `LCInfiniteScrollView.h`.

# License

YYImage is provided under the MIT license. See LICENSE file for details.