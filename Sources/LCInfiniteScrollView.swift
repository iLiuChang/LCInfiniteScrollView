//
//  LCInfiniteScrollView.swift
//  LCInfiniteScrollView
//
//  Created by LC on 2026/7/1.
//

import UIKit

@objc
public protocol LCInfiniteScrollViewDataSource: NSObjectProtocol {
    
    @objc(numberOfItemsInInfiniteScrollView:)
    func numberOfItems(in infiniteScrollView: LCInfiniteScrollView) -> Int
    
    @objc(infiniteScrollView:cellForItemAtIndex:)
    func infiniteScrollView(_ infiniteScrollView: LCInfiniteScrollView, cellForItemAt index: Int) -> UICollectionViewCell
    
}

@objc
public protocol LCInfiniteScrollViewDelegate: NSObjectProtocol {
    
    @objc(infiniteScrollView:shouldHighlightItemAtIndex:)
    optional func infiniteScrollView(_ infiniteScrollView: LCInfiniteScrollView, shouldHighlightItemAt index: Int) -> Bool
    
    @objc(infiniteScrollView:didHighlightItemAtIndex:)
    optional func infiniteScrollView(_ infiniteScrollView: LCInfiniteScrollView, didHighlightItemAt index: Int)
    
    @objc(infiniteScrollView:shouldSelectItemAtIndex:)
    optional func infiniteScrollView(_ infiniteScrollView: LCInfiniteScrollView, shouldSelectItemAt index: Int) -> Bool
    
    @objc(infiniteScrollView:didSelectItemAtIndex:)
    optional func infiniteScrollView(_ infiniteScrollView: LCInfiniteScrollView, didSelectItemAt index: Int)
    
    @objc(infiniteScrollView:willDisplayCell:forItemAtIndex:)
    optional func infiniteScrollView(_ infiniteScrollView: LCInfiniteScrollView, willDisplay cell: UICollectionViewCell, forItemAt index: Int)
    
    @objc(infiniteScrollView:didEndDisplayingCell:forItemAtIndex:)
    optional func infiniteScrollView(_ infiniteScrollView: LCInfiniteScrollView, didEndDisplaying cell: UICollectionViewCell, forItemAt index: Int)
    
    @objc(infiniteScrollViewWillBeginDragging:)
    optional func infiniteScrollViewWillBeginDragging(_ infiniteScrollView: LCInfiniteScrollView)
    
    @objc(infiniteScrollViewWillEndDragging:targetIndex:)
    optional func infiniteScrollViewWillEndDragging(_ infiniteScrollView: LCInfiniteScrollView, targetIndex: Int)
    
    @objc(infiniteScrollViewDidScroll:)
    optional func infiniteScrollViewDidScroll(_ infiniteScrollView: LCInfiniteScrollView)
    
    @objc(infiniteScrollViewDidEndScrollAnimation:)
    optional func infiniteScrollViewDidEndScrollAnimation(_ infiniteScrollView: LCInfiniteScrollView)
    
    @objc(infiniteScrollViewDidEndDecelerating:)
    optional func infiniteScrollViewDidEndDecelerating(_ infiniteScrollView: LCInfiniteScrollView)
    
}

open class LCInfiniteScrollView: UIView {
    
    @objc open weak var dataSource: LCInfiniteScrollViewDataSource?
    
    @objc open weak var delegate: LCInfiniteScrollViewDelegate?
    
    @objc open var scrollDirection: LCInfiniteScrollLayout.ScrollDirection {
        get { collectionViewLayout.scrollDirection }
        set { collectionViewLayout.scrollDirection = newValue }
    }
    
    @objc open var autoScrollTimeInterval: CGFloat = 0.0 {
        didSet {
            self.cancelTimer()
            if self.autoScrollTimeInterval > 0 {
                self.startTimer()
            }
        }
    }
    
    @objc open var interitemSpacing: CGFloat {
        get { collectionViewLayout.interitemSpacing }
        set { collectionViewLayout.interitemSpacing = newValue }
    }
        
    @objc open var disableInfiniteLoopForSingleItem: Bool = false
    
    @objc open var scrollOffset: CGFloat {
        let contentOffset = self.scrollDirection == .horizontal ? self.collectionView.contentOffset.x : self.collectionView.contentOffset.y
        return fmod(contentOffset / collectionViewLayout.itemInteritemSize, CGFloat(self.numberOfItems))
    }
    
    @objc open var panGestureRecognizer: UIPanGestureRecognizer {
        return self.collectionView.panGestureRecognizer
    }
    
    @objc open private(set) dynamic var currentIndex: Int = 0
    
    private let collectionViewLayout = LCInfiniteScrollLayout()
    private weak var collectionView: UICollectionView!
    private var timer: Timer?
    private var numberOfItems: Int = 0
    private var numberOfSections: Int = 0
    private var dequeingSection = 0
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    open override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        if newWindow != nil {
            self.startTimer()
        } else {
            self.cancelTimer()
        }
    }
    
    @objc(registerClass:forCellWithReuseIdentifier:)
    open func register(_ cellClass: Swift.AnyClass?, forCellWithReuseIdentifier identifier: String) {
        self.collectionView.register(cellClass, forCellWithReuseIdentifier: identifier)
    }
    
    @objc(registerNib:forCellWithReuseIdentifier:)
    open func register(_ nib: UINib?, forCellWithReuseIdentifier identifier: String) {
        self.collectionView.register(nib, forCellWithReuseIdentifier: identifier)
    }
    
    @objc(dequeueReusableCellWithReuseIdentifier:atIndex:)
    open func dequeueReusableCell(withReuseIdentifier identifier: String, at index: Int) -> UICollectionViewCell {
        let indexPath = IndexPath(item: index, section: self.dequeingSection)
        return self.collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
    }
    
    @objc(reloadData)
    open func reloadData() {
        self.collectionView.reloadData()
    }
    
    @objc(selectItemAtIndex:animated:)
    open func selectItem(at index: Int, animated: Bool) {
        let indexPath = self.nearbyIndexPath(for: index)
        let scrollPosition: UICollectionView.ScrollPosition = self.scrollDirection == .horizontal ? .centeredHorizontally : .centeredVertically
        self.collectionView.selectItem(at: indexPath, animated: animated, scrollPosition: scrollPosition)
    }
    
    @objc(deselectItemAtIndex:animated:)
    open func deselectItem(at index: Int, animated: Bool) {
        let indexPath = self.nearbyIndexPath(for: index)
        self.collectionView.deselectItem(at: indexPath, animated: animated)
    }
    
    @objc(scrollToItemAtIndex:animated:)
    open func scrollToItem(at index: Int, animated: Bool) {
        guard self.numberOfItems > 0, index >= 0 else { return }
        let index = min(index, self.numberOfItems - 1)
        let indexPath = self.numberOfSections > 1 ? self.nearbyIndexPath(for: index) : IndexPath(item: index, section: 0)
        let contentOffset = self.collectionViewLayout.contentOffset(for: indexPath)
        self.collectionView.setContentOffset(contentOffset, animated: animated)
    }
    
    @objc(indexForCell:)
    open func index(for cell: UICollectionViewCell) -> Int {
        guard let indexPath = self.collectionView.indexPath(for: cell) else {
            return NSNotFound
        }
        return indexPath.item
    }
    
    @objc(cellForItemAtIndex:)
    open func cellForItem(at index: Int) -> UICollectionViewCell? {
        let indexPath = self.nearbyIndexPath(for: index)
        return self.collectionView.cellForItem(at: indexPath)
    }
    
    @objc(startTimer)
    open func startTimer() {
        guard self.autoScrollTimeInterval > 0 && self.timer == nil else {
            return
        }
        self.timer = Timer.scheduledTimer(withTimeInterval: autoScrollTimeInterval, repeats: true) { [weak self] _ in
            self?.flipNext()
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
    
    private func commonInit() {
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: collectionViewLayout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.clear
        collectionView.contentInset = .zero
        collectionView.decelerationRate = UIScrollView.DecelerationRate.fast
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPrefetchingEnabled = false
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.scrollsToTop = false
        collectionView.isPagingEnabled = false

        self.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        self.collectionView = collectionView
    }
    
    private func flipNext() {
        guard let _ = self.superview, let _ = self.window, self.numberOfItems > 0, !self.collectionView.isTracking else {
            return
        }
        let contentOffset: CGPoint = {
            let indexPath = self.centermostIndexPath
            let section = self.numberOfSections > 1 ? (indexPath.section+(indexPath.item+1)/self.numberOfItems) : 0
            let item = (indexPath.item+1) % self.numberOfItems
            return self.collectionViewLayout.contentOffset(for: IndexPath(item: item, section: section))
        }()
        self.collectionView.setContentOffset(contentOffset, animated: true)
    }

    private func nearbyIndexPath(for index: Int) -> IndexPath {
        let currentIndex = self.currentIndex
        let currentSection = self.centermostIndexPath.section
        if abs(currentIndex-index) <= self.numberOfItems/2 {
            return IndexPath(item: index, section: currentSection)
        } else if (index-currentIndex >= 0) {
            return IndexPath(item: index, section: currentSection-1)
        } else {
            return IndexPath(item: index, section: currentSection+1)
        }
    }
    
    private var centermostIndexPath: IndexPath {
        guard self.numberOfItems > 0, self.collectionView.contentSize != .zero else {
            return IndexPath(item: 0, section: 0)
        }
        
        if self.collectionView.indexPathsForVisibleItems.count == 1 {
            return self.collectionView.indexPathsForVisibleItems[0]
        }
        
        let isHorizontal = self.scrollDirection == .horizontal
        let ruler = isHorizontal ? self.collectionView.bounds.midX : self.collectionView.bounds.midY
        let nearest = self.collectionView.indexPathsForVisibleItems.min { l, r in
            let lCenter = self.collectionViewLayout.frame(for: l)
            let rCenter = self.collectionViewLayout.frame(for: r)
            let ld = abs(ruler - (isHorizontal ? lCenter.midX : lCenter.midY))
            let rd = abs(ruler - (isHorizontal ? rCenter.midX : rCenter.midY))
            return ld < rd
        }
        return nearest ?? IndexPath(item: 0, section: 0)
    }
}

extension LCInfiniteScrollView: UICollectionViewDataSource,UICollectionViewDelegate {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let dataSource = self.dataSource else {
            return 1
        }
        self.numberOfItems = dataSource.numberOfItems(in: self)
        guard self.numberOfItems > 0 else {
            return 0
        }
        self.numberOfSections = (self.numberOfItems > 1 || !self.disableInfiniteLoopForSingleItem) ? Int(Int16.max)/self.numberOfItems : 1
        return self.numberOfSections
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.numberOfItems
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let index = indexPath.item
        self.dequeingSection = indexPath.section
        let cell = self.dataSource!.infiniteScrollView(self, cellForItemAt: index)
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        self.delegate?.infiniteScrollView?(self, shouldHighlightItemAt: indexPath.item) ?? true
    }
    
    public func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        self.delegate?.infiniteScrollView?(self, didHighlightItemAt: indexPath.item)
    }
    
    public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        self.delegate?.infiniteScrollView?(self, shouldSelectItemAt: indexPath.item) ?? true
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.delegate?.infiniteScrollView?(self, didSelectItemAt: indexPath.item)
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.delegate?.infiniteScrollView?(self, willDisplay: cell, forItemAt: indexPath.item)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.delegate?.infiniteScrollView?(self, didEndDisplaying: cell, forItemAt: indexPath.item)
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.numberOfItems > 0 {
            let currentIndex = lround(Double(self.scrollOffset)) % self.numberOfItems
            if (currentIndex != self.currentIndex) {
                self.currentIndex = currentIndex
            }
        }
        self.delegate?.infiniteScrollViewDidScroll?(self)
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.delegate?.infiniteScrollViewWillBeginDragging?(self)
        if self.autoScrollTimeInterval > 0 {
            self.cancelTimer()
        }
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if let function = self.delegate?.infiniteScrollViewWillEndDragging(_:targetIndex:) {
            let contentOffset = self.scrollDirection == .horizontal ? targetContentOffset.pointee.x : targetContentOffset.pointee.y
            let targetItem = lround(Double(contentOffset/self.collectionViewLayout.itemInteritemSize))
            function(self, targetItem % self.numberOfItems)
        }
        if self.autoScrollTimeInterval > 0 {
            self.startTimer()
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.delegate?.infiniteScrollViewDidEndDecelerating?(self)
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if collectionViewLayout.itemInteritemSize > 0 {
            adjustContentOffsetIfNeeded()
        }
        self.delegate?.infiniteScrollViewDidEndScrollAnimation?(self)
        
        func adjustContentOffsetIfNeeded() {
            if scrollDirection == .horizontal {
                let adjustedContentOffsetX = round(scrollView.contentOffset.x / collectionViewLayout.itemInteritemSize) * collectionViewLayout.itemInteritemSize
                if adjustedContentOffsetX != round(scrollView.contentOffset.x) {
                    scrollView.setContentOffset(CGPoint(x: adjustedContentOffsetX, y: scrollView.contentOffset.y), animated: true)
                }
            } else {
                let adjustedContentOffsetY = round(scrollView.contentOffset.y / collectionViewLayout.itemInteritemSize) * collectionViewLayout.itemInteritemSize
                if adjustedContentOffsetY != round(scrollView.contentOffset.y) {
                    scrollView.setContentOffset(CGPoint(x: scrollView.contentOffset.x, y: adjustedContentOffsetY), animated: true)
                }
            }
        }

    }
}
