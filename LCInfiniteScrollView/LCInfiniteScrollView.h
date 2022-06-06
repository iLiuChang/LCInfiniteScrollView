//  LCInfiniteScrollView.h
//
//  LCInfiniteScrollView (https://github.com/iLiuChang/LCInfiniteScrollView)
//
//  Created by 刘畅 on 2021/1/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class LCInfiniteScrollView;

@protocol LCInfiniteScrollViewDelegate <NSObject>

@required

/**
 The total number.
 */
- (NSInteger)numberOfIndexesInInfiniteScrollView:(LCInfiniteScrollView *)infiniteScrollView;

/**
 Set the reuse data.
 
 @param reusableView It is forbidden to modify the `frame` and `tag`, otherwise an error will occur.
 @param index index
 */
- (void)infiniteScrollView:(LCInfiniteScrollView *)infiniteScrollView displayReusableView:(UIView *)reusableView atIndex:(NSInteger)index;

@optional

/**
 Init reusable view. If no method is implemented, UIImageView is used by default.

 @return reusable View
 */
- (UIView *)reusableViewInInfiniteScrollView:(LCInfiniteScrollView *)infiniteScrollView;

/**
 Scroll index

 @param index index
 */
- (void)infiniteScrollView:(LCInfiniteScrollView *)infiniteScrollView didScrollIndex:(NSInteger)index;

/**
 Selected index.

 @param index index
 */
- (void)infiniteScrollView:(LCInfiniteScrollView *)infiniteScrollView didSelectIndex:(NSInteger)index;

@end

@interface LCInfiniteScrollView : UIView

/**
 Set delegate.
 */
@property (nonatomic, weak) id<LCInfiniteScrollViewDelegate> delegate;

/**
 NSTimer  runloop mode
 */
@property (nonatomic, copy, nullable) NSRunLoopMode timerRunLoopMode;

/**
 Auto scroll time interval, unit: second, default 2.5 seconds.
 */
@property (nonatomic, assign) NSTimeInterval autoScrollTimeInterval;

/**
 Whether automatic scrolling is required, default NO.
 
 If YES will create NSTimer, if NO will remove NSTimer.
 */
@property (nonatomic, assign) BOOL autoScroll;

/**
 Reload Data.
 
 If the timer is enabled, the timer will be stopped when `numberOfIndexInInfiniteScrollView:` is less than or equal to 1.
 */
- (void)reloadData;

@end

NS_ASSUME_NONNULL_END
