//
//  LCInfiniteScrollView.h
//  LCInfiniteScrollViewDemo
//
//  Created by 刘畅 on 2021/1/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class LCInfiniteScrollView;

@protocol LCInfiniteScrollViewDelegate <NSObject>

@required

/**
 总数
 */
- (NSInteger)numberOfIndexInInfiniteScrollView:(LCInfiniteScrollView *)infiniteScrollView;

/**
 设置图片
 
 @param reusableView 设置图片(禁止修改frame和tag)
 @param index 所在下标
 */
- (void)infiniteScrollView:(LCInfiniteScrollView *)infiniteScrollView reusableView:(UIView *)reusableView atIndex:(NSInteger)index;

@optional


/**
 重用视图(如果没有遵守此方法则为UIImageView)

 @return 1.不能为空 2.只能使用局部变量返回
 */
- (UIView *)reusableViewInInfiniteScrollView:(LCInfiniteScrollView *)infiniteScrollView;

/**
 滑动事件

 @param index 滑动下标
 */
- (void)infiniteScrollView:(LCInfiniteScrollView *)infiniteScrollView didScrollIndex:(NSInteger)index;

/**
 点击图片事件

 @param index 选中下标
 */
- (void)infiniteScrollView:(LCInfiniteScrollView *)infiniteScrollView didSelectIndex:(NSInteger)index;

@end

@interface LCInfiniteScrollView : UIView

/**
 代理
 */
@property (nonatomic, weak) id<LCInfiniteScrollViewDelegate> delegate;

/**
 是否自动滑动, 默认NO
 */
@property (nonatomic, assign) BOOL autoScroll;

/**
 自动滑动时间间隔, 单位: 秒, 默认2.5秒
 */
@property (nonatomic, assign) NSTimeInterval autoScrollTimeInterval;

/**
 刷新界面
 */
- (void)reloadData;

@end

NS_ASSUME_NONNULL_END
