//
//  LoopPagingView.swift
//  LoopPagingView
//
//  Created by LC on 2026/7/4.
//

import UIKit

@objcMembers
open class LoopPagingView: LoopCollectionView {

    @objc open var autoScrollTimeInterval: CGFloat = 0.0 {
        didSet {
            self.cancelTimer()
            if self.autoScrollTimeInterval > 0 {
                self.startTimer()
            }
        }
    }

    open override var cellLayout: LCInfiniteScrollCellLayout {
        get { .pagination }
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
        guard self.autoScrollTimeInterval > 0 && self.timer == nil else {
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

    @objc private func autoScrollToNextPage() {
        switch self.scrollDirection {
        case .vertical:
            let currentPage = lround(self.collectionView.contentOffset.y / self.collectionViewBoundsSize)
            self.collectionView.setContentOffset(CGPoint(x: 0, y: CGFloat(currentPage+1)*self.collectionViewBoundsSize), animated: true)
        default:
            let currentPage = lround(self.collectionView.contentOffset.x / self.collectionViewBoundsSize)
            self.collectionView.setContentOffset(CGPoint(x: CGFloat(currentPage+1)*self.collectionViewBoundsSize, y: 0), animated: true)
        }
    }

}

// MARK: - Override UIScrollViewDelegate
extension LoopPagingView {

    public override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        super.scrollViewWillBeginDragging(scrollView)
        if self.autoScrollTimeInterval > 0 {
            self.cancelTimer()
        }
    }

    public override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        super.scrollViewWillEndDragging(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
        if self.autoScrollTimeInterval > 0 {
            self.startTimer()
        }
    }
}
