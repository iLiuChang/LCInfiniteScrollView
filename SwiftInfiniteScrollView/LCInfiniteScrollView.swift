//  LCInfiniteScrollView.swift
// 
//  LCInfiniteScrollView (https://github.com/iLiuChang/LCInfiniteScrollView)
//
//  Created by 刘畅 on 2022/5/27.
//

import UIKit

@objc public protocol LCInfiniteScrollViewDelegate : NSObjectProtocol {
    
    func numberOfIndexes(in infiniteScrollView: LCInfiniteScrollView) -> Int

    func infiniteScrollView(_ infiniteScrollView: LCInfiniteScrollView, displayReusableView view: UIView, forIndex index: Int)

    func reusableView(in infiniteScrollView: LCInfiniteScrollView) -> UIView

    @objc optional func infiniteScrollView(_ infiniteScrollView: LCInfiniteScrollView, didScrollAt index: Int)

    @objc optional func infiniteScrollView(_ infiniteScrollView: LCInfiniteScrollView, didSelectAt index: Int)
    
}

open class LCInfiniteScrollView: UIView {

    /// Timer  runloop mode.
    open var timerRunLoopMode: RunLoop.Mode?
    
    /// Auto scroll time interval, unit: second.
    open var autoScrollTimeInterval: TimeInterval = 2.5
    /// Whether automatic scrolling is required, default `false`. If `true` will create `Timer`, if `false` will remove `Timer`.
    open var autoScroll: Bool = false {
        didSet {
            checkTimer()
        }
    }

    open weak var delegate: LCInfiniteScrollViewDelegate? {
        didSet {
            configData()
            reloadData()
        }
    }

    private var centerView: UIView?
    private var reusableView: UIView?
    private var scrollView: UIScrollView?
    private var timer: Timer?
    private var totalCount: Int = 0
    private var scrollIndex: Int = 0
    private var reusableIndex: Int = 0

    
    /// Reload data.
    /// If the timer is enabled, the timer will be stopped when `totalNumber` is less than or equal to 1.
    open func reloadData() {
        guard let delegate = self.delegate, let scrollView = self.scrollView, let centerView = self.centerView else {
            return
        }

        let totalCount = delegate.numberOfIndexes(in: self)
        self.totalCount = totalCount;
        if (totalCount <= 1) {
            removeTimer()
        } else {
            checkTimer()
        }
        scrollView.isScrollEnabled = totalCount > 1
        if (totalCount <= 0) {
            centerView.removeFromSuperview()
            return
        }

        if (centerView.tag >= totalCount) {
            self.reusableView?.tag = 0
            self.centerView?.tag = 0
            delegate.infiniteScrollView?(self, didScrollAt: centerView.tag)
        }
        
        if (centerView.superview == nil) {
            scrollView.addSubview(centerView)
        }
        delegate.infiniteScrollView(self, displayReusableView: centerView, forIndex: centerView.tag)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        let W = self.frame.width
        let H = self.frame.height
        scrollView?.frame = self.bounds
        centerView?.frame = CGRect(x: W, y: 0, width: W, height: H)
        scrollView?.contentSize = CGSize(width: W * 3.0, height: 0)
        scrollView?.setContentOffset(CGPoint(x: W, y: 0), animated: false)
    }

    open override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        if (newSuperview == nil) {
            removeTimer()
        }
    }
    
    deinit {
        removeTimer()
    }

}

private extension LCInfiniteScrollView {
    @objc func timerScroll() {
        if (totalCount <= 1) {
            return;
        }
        let w = self.bounds.size.width;
        if (w > 0) {
            self.scrollView?.setContentOffset(CGPoint(x: w*2, y: 0), animated: true)

        }
    }
    
    @objc func itemTap(_ tap:UIGestureRecognizer) {
        guard let delegate = self.delegate else {
            return
        }

        delegate.infiniteScrollView?(self, didSelectAt: tap.view!.tag)
    }

}

private extension LCInfiniteScrollView {
    func configData() {
       
        guard let delegate = self.delegate else {
            return
        }
        if (self.scrollView != nil) {
            self.scrollView!.removeFromSuperview()
        }
        self.scrollIndex = -1
        self.reusableIndex = -1
        
        let centerView = delegate.reusableView(in: self)
        let reusableView = delegate.reusableView(in: self)
        if (centerView == reusableView) {
            return
        }
        
        self.centerView = centerView
        self.reusableView = reusableView
        if (delegate.responds(to: #selector(delegate.infiniteScrollView(_:didSelectAt:)))) {
            centerView.isUserInteractionEnabled = true;
            centerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.itemTap(_:))))
            reusableView.isUserInteractionEnabled = true;
            reusableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.itemTap(_:))))
        }

        let scrollView = UIScrollView(frame: self.bounds)
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        self.addSubview(scrollView)
        scrollView.addSubview(centerView)
        centerView.tag = 0
        self.scrollView = scrollView
    }
    
    func checkTimer() {
        if (self.autoScroll) {
            addTimer()
        } else {
            removeTimer()
        }
    }
    
    func addTimer() {
        if (self.timer != nil && self.timer!.timeInterval == self.autoScrollTimeInterval) {
            return;
        }
        self.removeTimer()
        timer = Timer.scheduledTimer(timeInterval: self.autoScrollTimeInterval, target: self, selector: #selector(self.timerScroll), userInfo: nil, repeats: true )
        if (self.timerRunLoopMode != nil) {
            RunLoop.main.add(self.timer!, forMode: self.timerRunLoopMode!)
        }
    }

    func removeTimer() {
        if self.timer != nil {
            self.timer!.invalidate()
            self.timer = nil
        }
    }

    func scrollNext() {
        if (totalCount <= 0) {
            return
        }

        guard let delegate = self.delegate,
              let scrollView = self.scrollView else {
            return
        }

        if (self.centerView == nil || self.reusableView == nil) {
            return
        }
        let offsetX = scrollView.contentOffset.x
        let w = scrollView.frame.size.width
        
        var rx:CGFloat = 0.0
        var index:Int = 0
        if (offsetX > self.centerView!.frame.origin.x) { // left
            rx = scrollView.contentSize.width - w
            index = self.centerView!.tag + 1
            if (index >= totalCount){ index = 0 }
        } else { // right
            rx = 0
            index = self.centerView!.tag - 1
            if (index < 0) { index = totalCount - 1 }
        }

        self.reusableView!.frame = CGRect(x: rx, y: 0, width: w, height: scrollView.frame.size.height)
        self.reusableView!.tag = index
        if (reusableIndex != index) {
            delegate.infiniteScrollView(self, displayReusableView: self.reusableView!, forIndex: index)
        }
        reusableIndex = index

        if (offsetX <= 0 || offsetX >= w * 2)
        {
            let temp = centerView
            self.centerView = reusableView
            self.reusableView = temp

            self.centerView?.frame = self.reusableView!.frame
            scrollView.contentOffset = CGPoint(x: w, y: 0)
            self.reusableView?.removeFromSuperview()
        } else {
            scrollView.addSubview(self.reusableView!)
        }

        if (scrollIndex != self.centerView!.tag) {
            delegate.infiniteScrollView?(self, didScrollAt: self.centerView!.tag)
            scrollIndex = self.centerView!.tag
        }
        
    }
}

extension LCInfiniteScrollView: UIScrollViewDelegate {

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        DispatchQueue.main.async {
            self.scrollNext()
        }
    }

    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.removeTimer()
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if autoScroll {
            self.addTimer()
        }
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if autoScroll {
            self.addTimer()
        }
    }
}

