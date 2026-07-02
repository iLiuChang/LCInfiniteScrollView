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
    /// (horizontal: width or vertical: height) + interitemSpacing
    @objc public private(set) var itemInteritemSize: CGFloat = 0

    open override class var layoutAttributesClass: AnyClass {
        return LayoutAttributes.self
    }
    
    private var collectionViewSize: CGSize = .zero
    private var numberOfSections = 1
    private var numberOfItems = 0
    private var contentSize: CGSize = .zero
    private var leadingSpacing: CGFloat = 0

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
        self.collectionViewSize = collectionView.frame.size
        
        self.leadingSpacing = self.scrollDirection == .horizontal ? (collectionView.frame.width-self.collectionViewSize.width)*0.5 : (collectionView.frame.height-self.collectionViewSize.height)*0.5
        self.itemInteritemSize = (self.scrollDirection == .horizontal ? self.collectionViewSize.width : self.collectionViewSize.height) + self.interitemSpacing
        
        self.contentSize = {
            let numberOfItems = self.numberOfItems*self.numberOfSections
            switch self.scrollDirection {
                case .horizontal:
                    var contentSizeWidth: CGFloat = self.leadingSpacing*2
                    contentSizeWidth += CGFloat(numberOfItems-1)*self.interitemSpacing
                    contentSizeWidth += CGFloat(numberOfItems)*self.collectionViewSize.width
                    let contentSize = CGSize(width: contentSizeWidth, height: collectionView.frame.height)
                    return contentSize
                case .vertical:
                    var contentSizeHeight: CGFloat = self.leadingSpacing*2
                    contentSizeHeight += CGFloat(numberOfItems-1)*self.interitemSpacing
                    contentSizeHeight += CGFloat(numberOfItems)*self.collectionViewSize.height
                    let contentSize = CGSize(width: collectionView.frame.width, height: contentSizeHeight)
                    return contentSize
            }
        }()
        
        let currentIndex = dataSource?.currentIndex(in: self) ?? 0
        let newIndexPath = IndexPath(item: currentIndex, section: self.numberOfSections/2)
        let contentOffset = self.contentOffset(for: newIndexPath)
        let newBounds = CGRect(origin: contentOffset, size: collectionView.frame.size)
        collectionView.bounds = newBounds

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
        let numberOfItemsBefore = self.scrollDirection == .horizontal ? max(Int((rect.minX-self.leadingSpacing)/self.itemInteritemSize),0) : max(Int((rect.minY-self.leadingSpacing)/self.itemInteritemSize),0)
        let startPosition = self.leadingSpacing + CGFloat(numberOfItemsBefore)*self.itemInteritemSize
        let startIndex = numberOfItemsBefore
        var itemIndex = startIndex
        
        var origin = startPosition
        let maxPosition = self.scrollDirection == .horizontal ? min(rect.maxX,self.contentSize.width-self.collectionViewSize.width-self.leadingSpacing) : min(rect.maxY,self.contentSize.height-self.collectionViewSize.height-self.leadingSpacing)
        while origin-maxPosition <= max(CGFloat(100.0) * .ulpOfOne * abs(origin+maxPosition), .leastNonzeroMagnitude) {
            let indexPath = IndexPath(item: itemIndex%self.numberOfItems, section: itemIndex/self.numberOfItems)
            let attributes = self.layoutAttributesForItem(at: indexPath) as! LayoutAttributes
            layoutAttributes.append(attributes)
            itemIndex += 1
            origin += self.itemInteritemSize
        }
        return layoutAttributes
        
    }
    
    override open func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = LayoutAttributes(forCellWith: indexPath)
        attributes.indexPath = indexPath
        let frame = self.frame(for: indexPath)
        let center = CGPoint(x: frame.midX, y: frame.midY)
        attributes.center = center
        attributes.size = self.collectionViewSize
        return attributes
    }
    
    override open func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = self.collectionView else {
            return proposedContentOffset
        }
        var proposedContentOffset = proposedContentOffset
        
        func calculateTargetOffset(by proposedOffset: CGFloat, boundedOffset: CGFloat) -> CGFloat {
            var targetOffset: CGFloat
            switch velocity.x {
            case 0.3 ... CGFloat.greatestFiniteMagnitude:
                targetOffset = ceil(collectionView.contentOffset.x/self.itemInteritemSize) * self.itemInteritemSize
            case -CGFloat.greatestFiniteMagnitude ... -0.3:
                targetOffset = floor(collectionView.contentOffset.x/self.itemInteritemSize) * self.itemInteritemSize
            default:
                targetOffset = round(proposedOffset/self.itemInteritemSize) * self.itemInteritemSize
            }
            targetOffset = max(0, targetOffset)
            targetOffset = min(boundedOffset, targetOffset)
            return targetOffset
        }
        let proposedContentOffsetX: CGFloat = {
            if self.scrollDirection == .vertical {
                return proposedContentOffset.x
            }
            let boundedOffset = collectionView.contentSize.width-self.itemInteritemSize
            return calculateTargetOffset(by: proposedContentOffset.x, boundedOffset: boundedOffset)
        }()
        let proposedContentOffsetY: CGFloat = {
            if self.scrollDirection == .horizontal {
                return proposedContentOffset.y
            }
            let boundedOffset = collectionView.contentSize.height-self.itemInteritemSize
            return calculateTargetOffset(by: proposedContentOffset.y, boundedOffset: boundedOffset)
        }()
        proposedContentOffset = CGPoint(x: proposedContentOffsetX, y: proposedContentOffsetY)
        return proposedContentOffset
    }
    
    @objc(contentOffsetForIndexPath:)
    open func contentOffset(for indexPath: IndexPath) -> CGPoint {
        let origin = self.frame(for: indexPath).origin
        guard let collectionView = self.collectionView else {
            return origin
        }
        let contentOffsetX: CGFloat = {
            if self.scrollDirection == .vertical {
                return 0
            }
            let contentOffsetX = origin.x - (collectionView.frame.width*0.5-self.collectionViewSize.width*0.5)
            return contentOffsetX
        }()
        let contentOffsetY: CGFloat = {
            if self.scrollDirection == .horizontal {
                return 0
            }
            let contentOffsetY = origin.y - (collectionView.frame.height*0.5-self.collectionViewSize.height*0.5)
            return contentOffsetY
        }()
        let contentOffset = CGPoint(x: contentOffsetX, y: contentOffsetY)
        return contentOffset
    }
    
    @objc(frameForIndexPath:)
    open func frame(for indexPath: IndexPath) -> CGRect {
        guard let collectionView = self.collectionView else {
            return .zero
        }

        let numberOfItems = self.numberOfItems*indexPath.section + indexPath.item
        let originX: CGFloat = {
            if self.scrollDirection == .vertical {
                return (collectionView.frame.width-self.collectionViewSize.width)*0.5
            }
            return self.leadingSpacing + CGFloat(numberOfItems)*self.itemInteritemSize
        }()
        let originY: CGFloat = {
            if self.scrollDirection == .horizontal {
                return (collectionView.frame.height-self.collectionViewSize.height)*0.5
            }
            return self.leadingSpacing + CGFloat(numberOfItems)*self.itemInteritemSize
        }()
        let origin = CGPoint(x: originX, y: originY)
        let frame = CGRect(origin: origin, size: self.collectionViewSize)
        return frame
    }
        
    class LayoutAttributes: UICollectionViewLayoutAttributes {

        open var position: CGFloat = 0
        
        open override func isEqual(_ object: Any?) -> Bool {
            guard let object = object as? LayoutAttributes else {
                return false
            }
            var isEqual = super.isEqual(object)
            isEqual = isEqual && (self.position == object.position)
            return isEqual
        }
        
        open override func copy(with zone: NSZone? = nil) -> Any {
            let copy = super.copy(with: zone) as! LayoutAttributes
            copy.position = self.position
            return copy
        }
        
    }

}


