//
//  LCInfiniteScrollLayout.swift
//  LCInfiniteScrollView
//
//  Created by LC on 2026/7/1.
//

import UIKit

open class LCInfiniteScrollLayout: UICollectionViewLayout {
    
    @objc public enum ScrollDirection: Int {
        case horizontal
        case vertical
    }

    @objc open var scrollDirection: ScrollDirection = .horizontal
    @objc open var interitemSpacing: CGFloat = 0
    /// (horizontal: width or vertical: height) + interitemSpacing
    @objc public private(set) var itemInteritemSize: CGFloat = 0
    
    private var collectionViewSize: CGSize = .zero
    private var numberOfSections = 1
    private var numberOfItems = 0
    private var contentSize: CGSize = .zero

    override open func prepare() {
        guard let collectionView = self.collectionView else {
            return
        }
        let numberOfSections = collectionView.numberOfSections
        let numberOfItems = collectionView.numberOfItems(inSection: 0)
        guard self.collectionViewSize != collectionView.frame.size ||
        self.numberOfSections != numberOfSections ||
        self.numberOfItems != numberOfItems else {
            return
        }
        
        let oldItemInteritemSize = self.itemInteritemSize
        
        self.collectionViewSize = collectionView.frame.size
        self.numberOfSections = numberOfSections
        self.numberOfItems = numberOfItems
        
        self.itemInteritemSize = (self.scrollDirection == .horizontal ? self.collectionViewSize.width : self.collectionViewSize.height) + self.interitemSpacing
        
        let totalItems = self.numberOfItems * self.numberOfSections
        let contentLength = CGFloat(totalItems) * self.itemInteritemSize - self.interitemSpacing
        switch self.scrollDirection {
        case .horizontal:
            self.contentSize = CGSize(width: contentLength, height: self.collectionViewSize.height)
        case .vertical:
            self.contentSize = CGSize(width: self.collectionViewSize.width, height: contentLength)
        }
        
        let itemIndex: Int
        if self.numberOfItems > 0 && oldItemInteritemSize > 0 {
            let offset = self.scrollDirection == .horizontal ? collectionView.contentOffset.x : collectionView.contentOffset.y
            itemIndex = max(0, lround(Double(offset / oldItemInteritemSize)) % self.numberOfItems)
        } else {
            itemIndex = 0
        }
        let newIndexPath = IndexPath(item: itemIndex, section: self.numberOfSections / 2)
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
        let frame = self.frame(for: indexPath)
        attributes.center = CGPoint(x: frame.midX, y: frame.midY)
        attributes.size = self.collectionViewSize
        return attributes
    }
    
    override open func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = self.collectionView else {
            return proposedContentOffset
        }
        let isHorizontal = self.scrollDirection == .horizontal
        let v = isHorizontal ? velocity.x : velocity.y
        let currentOffset = isHorizontal ? collectionView.contentOffset.x : collectionView.contentOffset.y
        let proposedOffset = isHorizontal ? proposedContentOffset.x : proposedContentOffset.y
        let boundedOffset = (isHorizontal ? collectionView.contentSize.width : collectionView.contentSize.height) - self.itemInteritemSize
        var targetOffset: CGFloat
        switch v {
        case 0.3...: targetOffset = ceil(currentOffset / self.itemInteritemSize) * self.itemInteritemSize
        case ..<(-0.3): targetOffset = floor(currentOffset / self.itemInteritemSize) * self.itemInteritemSize
        default: targetOffset = round(proposedOffset / self.itemInteritemSize) * self.itemInteritemSize
        }
        targetOffset = min(max(0, targetOffset), boundedOffset)
        return isHorizontal
            ? CGPoint(x: targetOffset, y: proposedContentOffset.y)
            : CGPoint(x: proposedContentOffset.x, y: targetOffset)
    }
    
    @objc(contentOffsetForIndexPath:)
    open func contentOffset(for indexPath: IndexPath) -> CGPoint {
        let origin = self.frame(for: indexPath).origin
        return self.scrollDirection == .horizontal ? CGPoint(x: origin.x, y: 0) : CGPoint(x: 0, y: origin.y)
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
