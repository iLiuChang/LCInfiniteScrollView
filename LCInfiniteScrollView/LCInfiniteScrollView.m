//  LCInfiniteScrollView.m
//
//  LCInfiniteScrollView
//
//  Created by 刘畅 on 2021/1/14.
//

#import "LCInfiniteScrollView.h"

@interface LCInfiniteScrollView()<UIScrollViewDelegate>

@property (nonatomic, strong) UIView *reusableView;
@property (nonatomic, strong) UIView *centerView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSInteger scrollIndex;
@property (nonatomic, assign) NSInteger reusableIndex;
@property (nonatomic, assign) NSInteger totalCount;

@end

@implementation LCInfiniteScrollView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.autoScrollTimeInterval = 2.5;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.scrollView.frame = self.bounds;
    CGFloat w = self.scrollView.frame.size.width;
    CGFloat h = self.scrollView.frame.size.height;
    self.scrollView.contentSize = CGSizeMake(w * 3, 0);
    self.scrollView.contentOffset = CGPointMake(w, 0);
    self.centerView.frame = CGRectMake(w, 0, w, h);
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    if (!newSuperview) {
        [self removeTimer];
    }
}

- (void)setDelegate:(id<LCInfiniteScrollViewDelegate>)delegate {
    if (_delegate != delegate) {
        _delegate = delegate;

        if (_scrollView) {
            [_scrollView removeFromSuperview];
        }
        self.scrollIndex = -1;
        self.reusableIndex = -1;
        if ([delegate respondsToSelector:@selector(reusableViewInInfiniteScrollView:)]) {
            _centerView = [delegate reusableViewInInfiniteScrollView:self];
            if (!_centerView) {
                NSLog(@"infiniteScrollReusableView is nil");
                return;
            }

            _reusableView = [delegate reusableViewInInfiniteScrollView:self];
            if (!_reusableView) {
                NSLog(@"infiniteScrollReusableView is nil");
                return;
            }

            if ([_centerView isEqual:_reusableView]) {
                return;
            }
        } else {
            _centerView = [[UIImageView alloc] init];
            _reusableView = [[UIImageView alloc] init];
        }

        if ([delegate respondsToSelector:@selector(infiniteScrollView:didSelectIndex:)]) {
            _centerView.userInteractionEnabled = YES;
            UITapGestureRecognizer *centerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewTap:)];
            [_centerView addGestureRecognizer:centerTap];

            _reusableView.userInteractionEnabled = YES;
            UITapGestureRecognizer *reusableTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewTap:)];
            [_reusableView addGestureRecognizer:reusableTap];
        }

        _scrollView = [[UIScrollView alloc]initWithFrame:self.bounds];
        _scrollView.pagingEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
        _centerView.tag = 0;
        [_scrollView addSubview:_centerView];
    }
}

- (void)setAutoScroll:(BOOL)autoScroll {
    _autoScroll = autoScroll;
    [self checkTimer];
}

- (void)setAutoScrollTimeInterval:(NSTimeInterval)autoScrollTimeInterval {
    if (_autoScrollTimeInterval != autoScrollTimeInterval) {
        _autoScrollTimeInterval = autoScrollTimeInterval;
        if (_autoScroll) {
            [self removeTimer];
            [self addTimer];
        }
    }
}

- (void)checkTimer {
    if (_autoScroll) {
        [self addTimer];
    } else {
        [self removeTimer];
    }
}

- (void)addTimer {
    if (self.autoScrollTimeInterval <= 0) {
        return;
    }
    if (self.timer && self.timer.timeInterval == self.autoScrollTimeInterval) {
        return;
    }
    [self removeTimer];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.autoScrollTimeInterval target:self selector:@selector(loopScroll) userInfo:nil repeats:YES];
    if (self.timerRunLoopMode) {
        [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:self.timerRunLoopMode];
    }
}

- (void)removeTimer {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)reloadData {
    NSInteger totalCount = [self.delegate numberOfIndexInInfiniteScrollView:self];
    _totalCount = totalCount;
    if (totalCount <= 1) {
        [self removeTimer];
    } else {
        [self checkTimer];
    }
    self.scrollView.scrollEnabled = totalCount > 1;
    if (totalCount <= 0) {
        [_centerView removeFromSuperview];
        return;
    }

    if (_centerView.tag >= totalCount) {
        self.reusableView.tag = 0;
        self.centerView.tag = 0;
        if ([self.delegate respondsToSelector:@selector(infiniteScrollView:didScrollIndex:)]) {
            [self.delegate infiniteScrollView:self didScrollIndex:_centerView.tag];
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(infiniteScrollView:reusableView:atIndex:)]) {
        if (!_centerView.superview) {
            [_scrollView addSubview:_centerView];
        }
        [self.delegate infiniteScrollView:self reusableView:_centerView atIndex:_centerView.tag];
    }
}

- (void)imageViewTap:(UITapGestureRecognizer *)tap {
    if ([self.delegate respondsToSelector:@selector(infiniteScrollView:didSelectIndex:)]) {
        [self.delegate infiniteScrollView:self didSelectIndex:tap.view.tag];
    }
}

- (void)loopScroll {
    if (_totalCount <= 1) {
        return;
    }
    CGFloat w = self.scrollView.bounds.size.width;
    if (w > 0) {
        [self.scrollView setContentOffset:CGPointMake(w*2, 0) animated:YES];
    }
}

- (void)scrollNext {
    NSInteger totalCount = _totalCount;
    if (totalCount <= 0) {
        return;
    }
    CGFloat offsetX = self.scrollView.contentOffset.x;
    CGFloat w = self.scrollView.frame.size.width;
    
    CGFloat rx = 0;
    NSInteger index = 0;
    if (offsetX > _centerView.frame.origin.x) { // left
        rx = self.scrollView.contentSize.width - w;
        index = _centerView.tag + 1;
        if (index >= totalCount) index = 0;
    } else { // right
        rx = 0;
        index = _centerView.tag - 1;
        if (index < 0) index = totalCount - 1;
    }

    _reusableView.frame = CGRectMake(rx, 0, w, self.scrollView.frame.size.height);
    _reusableView.tag = index;
    if (_reusableIndex != index) {
        [self.delegate infiniteScrollView:self reusableView:_reusableView atIndex:index];
    }
    _reusableIndex = index;

    if (offsetX <= 0 || offsetX >= w * 2)
    {
        UIView *temp = _centerView;
        _centerView = _reusableView;
        _reusableView = temp;

        _centerView.frame = _reusableView.frame;
        self.scrollView.contentOffset = CGPointMake(w, 0);
        [_reusableView removeFromSuperview];
    } else {
        [_scrollView addSubview:_reusableView];
    }

    if (_scrollIndex != _centerView.tag) {
        if ([self.delegate respondsToSelector:@selector(infiniteScrollView:didScrollIndex:)]) {
            [self.delegate infiniteScrollView:self didScrollIndex:_centerView.tag];
        }
        _scrollIndex = _centerView.tag;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self scrollNext];
    });
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self removeTimer];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self addTimer];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self addTimer];
}

@end
