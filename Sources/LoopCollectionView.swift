//
//  LoopCollectionView.swift
//  LoopCollectionView
//
//  Created by LC on 2026/7/1.
//

import UIKit

@objc
public protocol LoopCollectionViewDataSource: NSObjectProtocol {
    
    @objc(numberOfItemsInInfiniteScrollView:)
    func numberOfItems(in loopCollectionView: LoopCollectionView) -> Int
    
    @objc(loopCollectionView:cellForItemAtIndex:)
    func loopCollectionView(_ loopCollectionView: LoopCollectionView, cellForItemAt index: Int) -> UICollectionViewCell
    
}

@objc
public protocol LoopCollectionViewDelegate: NSObjectProtocol {
    
    @objc(loopCollectionView:shouldHighlightItemAtIndex:)
    optional func loopCollectionView(_ loopCollectionView: LoopCollectionView, shouldHighlightItemAt index: Int) -> Bool
    
    @objc(loopCollectionView:didHighlightItemAtIndex:)
    optional func loopCollectionView(_ loopCollectionView: LoopCollectionView, didHighlightItemAt index: Int)
    
    @objc(loopCollectionView:shouldSelectItemAtIndex:)
    optional func loopCollectionView(_ loopCollectionView: LoopCollectionView, shouldSelectItemAt index: Int) -> Bool
    
    @objc(loopCollectionView:didSelectItemAtIndex:)
    optional func loopCollectionView(_ loopCollectionView: LoopCollectionView, didSelectItemAt index: Int)
    
    @objc(loopCollectionView:willDisplayCell:forItemAtIndex:)
    optional func loopCollectionView(_ loopCollectionView: LoopCollectionView, willDisplay cell: UICollectionViewCell, forItemAt index: Int)
    
    @objc(loopCollectionView:didEndDisplayingCell:forItemAtIndex:)
    optional func loopCollectionView(_ loopCollectionView: LoopCollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt index: Int)
    
    @objc(loopCollectionViewWillBeginDragging:)
    optional func loopCollectionViewWillBeginDragging(_ loopCollectionView: LoopCollectionView)
    
    @objc(loopCollectionViewWillEndDragging:)
    optional func loopCollectionViewWillEndDragging(_ loopCollectionView: LoopCollectionView)
    
    @objc(loopCollectionViewDidScroll:)
    optional func loopCollectionViewDidScroll(_ loopCollectionView: LoopCollectionView)
    
    @objc(loopCollectionViewDidEndScrollAnimation:)
    optional func loopCollectionViewDidEndScrollAnimation(_ loopCollectionView: LoopCollectionView)
    
    @objc(loopCollectionViewDidEndDecelerating:)
    optional func loopCollectionViewDidEndDecelerating(_ loopCollectionView: LoopCollectionView)
    
    @objc(loopCollectionViewDidEndDragging:willDecelerate:)
    optional func loopCollectionViewDidEndDragging(_ loopCollectionView: LoopCollectionView, willDecelerate decelerate: Bool)
}

@objcMembers
public class LCInfiniteScrollCellLayout: NSObject {
    public class var page: LCInfiniteScrollCellLayout {
        LCInfiniteScrollCellLayout(size: 0, spacing: 0)
    }
    public var size: CGFloat
    public var spacing: CGFloat
    
    public init(size: CGFloat, spacing: CGFloat) {
        self.size = size
        self.spacing = spacing
    }
}

// MARK: - LoopCollectionView

@objc
open class LoopCollectionView: UIView {

    @objc open weak var dataSource: LoopCollectionViewDataSource?
    @objc open weak var delegate: LoopCollectionViewDelegate?

    /// Scroll direction. Default is .horizontal
    @objc open var scrollDirection: UICollectionView.ScrollDirection = .horizontal {
        didSet {
            if scrollDirection != oldValue {
                collectionViewLayout.scrollDirection = scrollDirection
                guard numberOfItems > 0 && collectionViewBoundsSize > 0 else {
                    return
                }
                reloadLayoutAndData()
                scrollToFirstItem()
            }
        }
    }

    @objc open var itemSize: CGFloat = 0 {
        didSet {
            if itemSize != oldValue {
                let isPagingEnabled = collectionView.isPagingEnabled
                collectionView.isPagingEnabled = itemSize <= 0
                guard numberOfItems > 0 && collectionViewBoundsSize > 0 else {
                    return
                }
                reloadLayoutAndData()
                if isPagingEnabled != collectionView.isPagingEnabled {
                    scrollToFirstItem()
                }
            }
        }
    }

    @objc open var itemSpacing: CGFloat = 0 {
        didSet {
            if itemSize != oldValue {
                guard numberOfItems > 0 && collectionViewBoundsSize > 0 else {
                    return
                }
                reloadLayoutAndData()
            }
        }
    }

    @objc open var panGestureRecognizer: UIPanGestureRecognizer {
        return self.collectionView.panGestureRecognizer
    }

    // MARK: - Private Properties
    internal var numberOfItems: Int = 0
    private var cellSize: CGFloat = 0
    private var cellSpacing: CGFloat = 0
    private var numberOfBoundaryElements = 0
    private var totalItemsWithBoundary = 0
    private var collectionViewSize: CGSize = .zero
    private let collectionViewLayout = UICollectionViewFlowLayout()
    internal lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
    internal var collectionViewBoundsSize: CGFloat {
        scrollDirection == .vertical ? collectionViewSize.height : collectionViewSize.width
    }


    // MARK: - Init

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }

    private func commonInit() {
        collectionViewLayout.scrollDirection = scrollDirection
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.clear
        collectionView.contentInset = .zero
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.scrollsToTop = false
        collectionView.isPagingEnabled = true
        
        self.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        if collectionViewSize != frame.size {
            collectionViewSize = frame.size
            reloadLayoutAndData()
            if itemSize <= 0 {
                switch self.scrollDirection {
                case .vertical:
                    let currentPage = round(collectionView.contentOffset.y / collectionViewBoundsSize)
                    let targetOffset = CGPoint(x: 0, y: currentPage * collectionViewBoundsSize)
                    collectionView.setContentOffset(targetOffset, animated: false)
                default:
                    let currentPage = round(collectionView.contentOffset.x / collectionViewBoundsSize)
                    let targetOffset = CGPoint(x: currentPage * collectionViewBoundsSize, y: 0)
                    collectionView.setContentOffset(targetOffset, animated: false)
                }
            }
        }
    }

    // MARK: - Public API

    @objc(registerClass:forCellWithReuseIdentifier:)
    open func register(_ cellClass: AnyClass?, forCellWithReuseIdentifier identifier: String) {
        collectionView.register(cellClass, forCellWithReuseIdentifier: identifier)
    }

    @objc(registerNib:forCellWithReuseIdentifier:)
    open func register(_ nib: UINib?, forCellWithReuseIdentifier identifier: String) {
        collectionView.register(nib, forCellWithReuseIdentifier: identifier)
    }

    @objc(dequeueReusableCellWithReuseIdentifier:forIndex:)
    open func dequeueReusableCell(withReuseIdentifier identifier: String, for index: Int) -> UICollectionViewCell {
        let indexPath = IndexPath(item: index, section: 0)
        return collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
    }

    @objc(scrollToItemAtIndex:animated:)
    open func scrollToItem(at index: Int, animated: Bool) {
        guard self.numberOfItems > 0, index >= 0 else { return }
        let bIndex = boundaryIndex(forOriginalIndex: index)
        let indexPath = IndexPath(item: bIndex, section: 0)
        let scrollPosition: UICollectionView.ScrollPosition = scrollDirection == .horizontal ? .left : .top
        collectionView.scrollToItem(at: indexPath, at: scrollPosition, animated: animated)
    }

    @objc(selectItemAtIndex:animated:)
    open func selectItem(at index: Int, animated: Bool) {
        guard self.numberOfItems > 0, index >= 0 else { return }
        let bIndex = boundaryIndex(forOriginalIndex: index)
        let indexPath = IndexPath(item: bIndex, section: 0)
        let scrollPosition: UICollectionView.ScrollPosition = self.scrollDirection == .horizontal ? .centeredHorizontally : .centeredVertically
        self.collectionView.selectItem(at: indexPath, animated: animated, scrollPosition: scrollPosition)
    }
    
    @objc(deselectItemAtIndex:animated:)
    open func deselectItem(at index: Int, animated: Bool) {
        guard self.numberOfItems > 0, index >= 0 else { return }
        let bIndex = boundaryIndex(forOriginalIndex: index)
        let indexPath = IndexPath(item: bIndex, section: 0)
        self.collectionView.deselectItem(at: indexPath, animated: animated)
    }

    @objc(cellForItemAtIndex:)
    open func cellForItem(at index: Int) -> UICollectionViewCell? {
        guard self.numberOfItems > 0, index >= 0 else { return nil }
        let bIndex = boundaryIndex(forOriginalIndex: index)
        let indexPath = IndexPath(item: bIndex, section: 0)
        return self.collectionView.cellForItem(at: indexPath)
    }

    @objc(indexForCell:)
    open func index(for cell: UICollectionViewCell) -> Int {
        guard let indexPath = self.collectionView.indexPath(for: cell) else {
            return NSNotFound
        }
        return originalIndex(forBoundaryIndex: indexPath.item)
    }

    @objc(reloadData)
    open func reloadData() {
        let oldNumberOfItems = numberOfItems
        self.numberOfItems = dataSource?.numberOfItems(in: self) ?? 0
        configureBoundary()
        collectionView.reloadData()
        if (oldNumberOfItems == 0 && numberOfItems > 0) {
            scrollToFirstItem()
        }
    }
}

extension LoopCollectionView {
    private func configureBoundary() {
        guard numberOfItems > 0, collectionViewBoundsSize > 0 else {
            numberOfBoundaryElements = 0
            totalItemsWithBoundary = 0
            return
        }
        if cellSize > 0 {
            numberOfBoundaryElements = lround(collectionViewBoundsSize / cellSize)
        } else {
            numberOfBoundaryElements = 1
        }
        totalItemsWithBoundary = numberOfItems + 2 * numberOfBoundaryElements
    }

    private func configureCellLayout() {
        guard collectionViewBoundsSize > 0 else {
            return
        }
        if itemSize > 0 {
            cellSize = itemSize
            cellSpacing = itemSpacing
        } else {
            cellSize = collectionViewBoundsSize
            cellSpacing = 0
        }
    }

    private func reloadLayoutAndData() {
        configureCellLayout()
        configureBoundary()
        collectionView.reloadData()
    }
    
    private func scrollToFirstItem() {
        guard numberOfItems > 0 else {
            return
        }

        DispatchQueue.main.async {
            self.scrollToItem(at: 0, animated: false)
        }
    }
    
    // MARK: - Index Mapping

    private func originalIndex(forBoundaryIndex index: Int) -> Int {
        guard numberOfItems > 0 else { return 0 }
        let difference = index - numberOfBoundaryElements
        if difference < 0 {
            let idx = numberOfItems + difference
            return abs(idx % numberOfItems)
        } else if difference < numberOfItems {
            return difference
        } else {
            return abs((difference - numberOfItems) % numberOfItems)
        }
    }

    private func boundaryIndex(forOriginalIndex index: Int) -> Int {
        return index + numberOfBoundaryElements
    }
}
// MARK: - UICollectionViewDelegateFlowLayout

extension LoopCollectionView: UICollectionViewDelegateFlowLayout {

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return cellSpacing
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumcellSpacingForSectionAt section: Int) -> CGFloat {
        return cellSpacing
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch scrollDirection {
        case .vertical:
            let width = collectionView.bounds.size.width
            return CGSize(width: width, height: cellSize)
        default:
            return CGSize(width: cellSize, height: collectionView.bounds.size.height)
        }
    }

    public func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        let idx = originalIndex(forBoundaryIndex: indexPath.item)
        return delegate?.loopCollectionView?(self, shouldHighlightItemAt: idx) ?? true
    }

    public func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let idx = originalIndex(forBoundaryIndex: indexPath.item)
        delegate?.loopCollectionView?(self, didHighlightItemAt: idx)
    }

    public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let idx = originalIndex(forBoundaryIndex: indexPath.item)
        return delegate?.loopCollectionView?(self, shouldSelectItemAt: idx) ?? true
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let idx = originalIndex(forBoundaryIndex: indexPath.item)
        delegate?.loopCollectionView?(self, didSelectItemAt: idx)
    }

    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let idx = originalIndex(forBoundaryIndex: indexPath.item)
        delegate?.loopCollectionView?(self, willDisplay: cell, forItemAt: idx)
    }

    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let idx = originalIndex(forBoundaryIndex: indexPath.item)
        delegate?.loopCollectionView?(self, didEndDisplaying: cell, forItemAt: idx)
    }

    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        delegate?.loopCollectionViewWillBeginDragging?(self)
    }

    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        delegate?.loopCollectionViewWillEndDragging?(self)
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.loopCollectionViewDidScroll?(self)

        guard numberOfItems > 0 else { return }
        let boundarySize = CGFloat(numberOfBoundaryElements) * cellSize + (CGFloat(numberOfBoundaryElements) * cellSpacing)
        let contentOffsetValue = scrollDirection == .horizontal ? scrollView.contentOffset.x : scrollView.contentOffset.y
        let scrollViewContentSizeValue: CGFloat = scrollDirection == .vertical ? collectionView.contentSize.height : collectionView.contentSize.width
        if contentOffsetValue >= (scrollViewContentSizeValue - boundarySize) {
            let offset = boundarySize - cellSpacing
            let updatedOffsetPoint = scrollDirection == .horizontal ?
                CGPoint(x: offset, y: 0) : CGPoint(x: 0, y: offset)
            scrollView.contentOffset = updatedOffsetPoint
        } else if contentOffsetValue <= 0 {
            let boundaryLessSize = CGFloat(numberOfItems) * cellSize + (CGFloat(numberOfItems) * cellSpacing)
            let updatedOffsetPoint = scrollDirection == .horizontal ?
                CGPoint(x: boundaryLessSize, y: 0) : CGPoint(x: 0, y: boundaryLessSize)
            scrollView.contentOffset = updatedOffsetPoint
        }
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        delegate?.loopCollectionViewDidEndDecelerating?(self)
    }

    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        delegate?.loopCollectionViewDidEndScrollAnimation?(self)
    }

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        delegate?.loopCollectionViewDidEndDragging?(self, willDecelerate: decelerate)
    }
}

// MARK: - UICollectionViewDataSource

extension LoopCollectionView: UICollectionViewDataSource {

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return totalItemsWithBoundary
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let dataSource = self.dataSource else {
            return UICollectionViewCell()
        }
        let idx = originalIndex(forBoundaryIndex: indexPath.item)
        return dataSource.loopCollectionView(self, cellForItemAt: idx)
    }
}


