//
//  LCInfiniteScrollLayout.swift
//  LCInfiniteScrollView
//
//  Created by LC on 2026/7/1.
//

import UIKit

@objc
public protocol LCInfiniteScrollLayoutDataSource: NSObjectProtocol {
    @objc(currentIndexInInfiniteScrollLayout:)
    func currentIndex(in infiniteScrollLayout: LCInfiniteScrollLayout) -> Int
}

open class LCInfiniteScrollLayout: UICollectionViewLayout {
    
    @objc public enum ScrollDirection: Int {
        case horizontal
        case vertical
    }

    @objc open weak var dataSource: LCInfiniteScrollLayoutDataSource?
    @objc open var scrollDirection: ScrollDirection = .horizontal
    @objc open var interitemSpacing: CGFloat = 0
    @objc public private(set) var itemInteritemSize: CGFloat = 0
    
    private var collectionViewSize: CGSize = .zero
    private var numberOfSections = 1
    private var numberOfItems = 0
    private var contentSize: CGSize = .zero

    override open func prepare() {
        guard let collectionView = self.collectionView else {
            return
        }
        
        guard self.collectionViewSize != collectionView.frame.size else {
            return
        }
        
        self.collectionViewSize = collectionView.frame.size
        self.numberOfSections = collectionView.numberOfSections
        self.numberOfItems = collectionView.numberOfItems(inSection: 0)
        
        self.itemInteritemSize = (self.scrollDirection == .horizontal ? self.collectionViewSize.width : self.collectionViewSize.height) + self.interitemSpacing
        
        self.contentSize = {
            let totalItems = self.numberOfItems * self.numberOfSections
            switch self.scrollDirection {
                case .horizontal:
                    var width: CGFloat = CGFloat(totalItems - 1) * self.interitemSpacing
                    width += CGFloat(totalItems) * self.collectionViewSize.width
                    return CGSize(width: width, height: collectionView.frame.height)
                case .vertical:
                    var height: CGFloat = CGFloat(totalItems - 1) * self.interitemSpacing
                    height += CGFloat(totalItems) * self.collectionViewSize.height
                    return CGSize(width: collectionView.frame.width, height: height)
            }
        }()
        
        let currentIndex = dataSource?.currentIndex(in: self) ?? 0
        let newIndexPath = IndexPath(item: currentIndex, section: self.numberOfSections / 2)
        let offset = self.contentOffset(for: newIndexPath)
        collectionView.bounds = CGRect(origin: offset, size: collectionView.frame.size)
    }
    
    override open var collectionViewContentSize: CGSize {
        return self.contentSize
    }
    
    override open func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        guard self.itemInteritemSize > 0, !rect.isEmpty else {
            return layoutAttributes
        }
        let rect = rect.intersection(CGRect(origin: .zero, size: self.contentSize))
        guard !rect.isEmpty else {
            return layoutAttributes
        }
        let numberOfItemsBefore = self.scrollDirection == .horizontal ? max(Int(rect.minX / self.itemInteritemSize), 0) : max(Int(rect.minY / self.itemInteritemSize), 0)
        var itemIndex = numberOfItemsBefore
        var origin = CGFloat(numberOfItemsBefore) * self.itemInteritemSize
        let maxPosition = self.scrollDirection == .horizontal ? min(rect.maxX, self.contentSize.width - self.collectionViewSize.width) : min(rect.maxY, self.contentSize.height - self.collectionViewSize.height)
        while origin - maxPosition <= max(CGFloat(100.0) * .ulpOfOne * abs(origin + maxPosition), .leastNonzeroMagnitude) {
            let indexPath = IndexPath(item: itemIndex % self.numberOfItems, section: itemIndex / self.numberOfItems)
            if let attributes = self.layoutAttributesForItem(at: indexPath) {
                layoutAttributes.append(attributes)
                itemIndex += 1
                origin += self.itemInteritemSize
            }
        }
        return layoutAttributes
    }
    
    override open func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        attributes.indexPath = indexPath
        let frame = self.frame(for: indexPath)
        attributes.center = CGPoint(x: frame.midX, y: frame.midY)
        attributes.size = self.collectionViewSize
        return attributes
    }
    
    override open func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = self.collectionView else {
            return proposedContentOffset
        }
        var proposedContentOffset = proposedContentOffset
        let v = self.scrollDirection == .horizontal ? velocity.x : velocity.y
        let currentOffset = self.scrollDirection == .horizontal ? collectionView.contentOffset.x : collectionView.contentOffset.y
        let contentLength = self.scrollDirection == .horizontal ? collectionView.contentSize.width : collectionView.contentSize.height
        
        func calculateTargetOffset(by proposedOffset: CGFloat) -> CGFloat {
            var targetOffset: CGFloat
            switch v {
            case 0.3 ... CGFloat.greatestFiniteMagnitude:
                targetOffset = ceil(currentOffset / self.itemInteritemSize) * self.itemInteritemSize
            case -CGFloat.greatestFiniteMagnitude ... -0.3:
                targetOffset = floor(currentOffset / self.itemInteritemSize) * self.itemInteritemSize
            default:
                targetOffset = round(proposedOffset / self.itemInteritemSize) * self.itemInteritemSize
            }
            let boundedOffset = contentLength - self.itemInteritemSize
            targetOffset = max(0, targetOffset)
            targetOffset = min(boundedOffset, targetOffset)
            return targetOffset
        }
        
        switch self.scrollDirection {
        case .horizontal:
            proposedContentOffset.x = calculateTargetOffset(by: proposedContentOffset.x)
        case .vertical:
            proposedContentOffset.y = calculateTargetOffset(by: proposedContentOffset.y)
        }
        return proposedContentOffset
    }
    
    @objc(contentOffsetForIndexPath:)
    open func contentOffset(for indexPath: IndexPath) -> CGPoint {
        let origin = self.frame(for: indexPath).origin
        switch self.scrollDirection {
        case .horizontal:
            return CGPoint(x: origin.x, y: 0)
        case .vertical:
            return CGPoint(x: 0, y: origin.y)
        }
    }
    
    @objc(frameForIndexPath:)
    open func frame(for indexPath: IndexPath) -> CGRect {
        let numberOfItems = self.numberOfItems * indexPath.section + indexPath.item
        switch self.scrollDirection {
        case .horizontal:
            return CGRect(x: CGFloat(numberOfItems) * self.itemInteritemSize, y: 0, width: self.collectionViewSize.width, height: self.collectionViewSize.height)
        case .vertical:
            return CGRect(x: 0, y: CGFloat(numberOfItems) * self.itemInteritemSize, width: self.collectionViewSize.width, height: self.collectionViewSize.height)
        }
    }
}
