//
//  LoopPagingView.swift
//  LoopPagingView
//
//  Created by LC on 2026/7/4.
//

import UIKit

open class LoopPagingView: LoopCollectionView {

    /// Auto-scroll interval in seconds. 0 disables auto-scroll.
    @objc open var autoScrollTimeInterval: CGFloat = 0.0 {
        didSet {
            self.cancelTimer()
            if self.autoScrollTimeInterval > 0 {
                self.startTimer()
            }
        }
    }

    /// When true, a single item won't loop and scrolling is disabled.
    @objc open var disableLoopForSingleItem: Bool = false
    
    open override var itemSize: CGFloat {
        get { return 0 }
        set {}
    }
    
    open override var itemSpacing: CGFloat {
        get { return 0 }
        set {}
    }

    open override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        if newWindow != nil {
            self.startTimer()
        } else {
            self.cancelTimer()
        }
    }
    
    private var timer: Timer?

    @objc(startTimer)
    open func startTimer() {
        guard self.autoScrollTimeInterval > 0,
              self.timer == nil,
              self.numberOfItems > 0 else {
            return
        }
        
        if disableLoopForSingleItem && numberOfItems == 1 {
            return
        }
        
        self.timer = Timer.scheduledTimer(withTimeInterval: autoScrollTimeInterval, repeats: true) { [weak self] _ in
            self?.autoScrollToNextPage()
        }
        RunLoop.current.add(self.timer!, forMode: .common)
    }
    
    @objc(cancelTimer)
    open func cancelTimer() {
        guard self.timer != nil else {
            return
        }
        self.timer!.invalidate()
        self.timer = nil
    }

    open override func reloadData() {
        super.reloadData()
        if (disableLoopForSingleItem && numberOfItems == 1) || numberOfItems == 0 {
            cancelTimer()
            collectionView.isScrollEnabled = false
        } else {
            startTimer()
            collectionView.isScrollEnabled = true
        }
    }
    
    private func autoScrollToNextPage() {
        switch self.scrollDirection {
        case .vertical:
            let currentPage = round(self.collectionView.contentOffset.y / self.collectionViewBoundsSize)
            self.collectionView.setContentOffset(CGPoint(x: 0, y: CGFloat(currentPage+1)*self.collectionViewBoundsSize), animated: true)
        default:
            let currentPage = round(self.collectionView.contentOffset.x / self.collectionViewBoundsSize)
            self.collectionView.setContentOffset(CGPoint(x: CGFloat(currentPage+1)*self.collectionViewBoundsSize, y: 0), animated: true)
        }
    }

}

// MARK: - Override UIScrollViewDelegate
extension LoopPagingView {

    public override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        super.scrollViewWillBeginDragging(scrollView)
        if autoScrollTimeInterval > 0 {
            cancelTimer()
        }
    }

    public override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        super.scrollViewWillEndDragging(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
        if autoScrollTimeInterval > 0 && numberOfItems > 0 {
            startTimer()
        }
    }
}
