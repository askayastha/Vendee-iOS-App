//
//  FlickLayout.swift
//  RWDevCon
//
//  Created by Mic Pringle on 27/02/2015.
//  Copyright (c) 2015 Ray Wenderlich. All rights reserved.
//

import UIKit

/* The heights are declared as constants outside of the class so they can be easily referenced elsewhere */
struct FlickLayoutConstants {
    struct Cell {
        /* The height of the non-featured cell */
        static let standardHeight: CGFloat = ScreenConstants.height * 0.5
        /* The height of the first visible cell */
        static let featuredHeight: CGFloat = ScreenConstants.height
    }
}

class FlickLayout: UICollectionViewLayout {
  
    // MARK: Properties and Variables
  
    /* The amount the user needs to scroll before the featured cell changes */
    let dragOffset: CGFloat = FlickLayoutConstants.Cell.featuredHeight - FlickLayoutConstants.Cell.standardHeight
  
    var cache = [CustomLayoutAttributes]()
  
    /* Returns the item index of the currently featured cell */
    var featuredItemIndex: Int {
        get {
            /* Use max to make sure the featureItemIndex is never < 0 */
            return max(0, Int(collectionView!.contentOffset.y / dragOffset))
        }
    }
  
    /* Returns a value between 0 and 1 that represents how close the next cell is to becoming the featured cell */
    var nextItemPercentageOffset: CGFloat {
        get {
            return (collectionView!.contentOffset.y / dragOffset) - CGFloat(featuredItemIndex)
        }
    }
  
    /* Returns the width of the collection view */
    var width: CGFloat {
        get {
            return CGRectGetWidth(collectionView!.bounds)
        }
    }
  
    /* Returns the height of the collection view */
    var height: CGFloat {
        get {
            return CGRectGetHeight(collectionView!.bounds)
        }
    }
  
    /* Returns the number of items in the collection view */
    var numberOfItems: Int {
        get {
          return collectionView!.numberOfItemsInSection(0)
        }
    }
  
    // MARK: UICollectionViewLayout
  
    /* Return the size of all the content in the collection view */
    override func collectionViewContentSize() -> CGSize {
        let contentHeight = (CGFloat(numberOfItems) * dragOffset) + (height - dragOffset)
        return CGSize(width: width, height: contentHeight)
    }
  
  override func prepareLayout() {
//    println("yOffset: \(collectionView!.contentOffset.y)")
    cache.removeAll(keepCapacity: false)
    
    let standardHeight = FlickLayoutConstants.Cell.standardHeight
    let featuredHeight = FlickLayoutConstants.Cell.featuredHeight
    
    var frame = CGRectZero
    var y: CGFloat = 0
    
    for item in 0..<numberOfItems {
        // Create an index path to the current cell, then get its current attributes.
        let indexPath = NSIndexPath(forItem: item, inSection: 0)
        let attributes = CustomLayoutAttributes(forCellWithIndexPath: indexPath)
        
        // Prepare the cell to move up or down. Since the majority of cells will not be featured -- there are many more standard cells than the featured cells -- it defaults to the standardHeight.
        attributes.zIndex = item
        var height = standardHeight
        
        // Determine the current cell's status -- featured, next or standard. In the case of the latter, you do nothing.
        if indexPath.item == featuredItemIndex {
            // If the cell is currently in the featured cell position, calculate the yOffset and use that to derive the new y value for the cell. After that, you set the cell's height to be the featured height.
//            let yOffset = featuredHeight * nextItemPercentageOffset
//            
//            y = collectionView!.contentOffset.y - yOffset
//            height = standardHeight - max((standardHeight - featuredHeight) * nextItemPercentageOffset, 0)
            
            let yOffset = standardHeight * nextItemPercentageOffset
            y = collectionView!.contentOffset.y - yOffset
            height = featuredHeight
            
            let newHeight = standardHeight + max((featuredHeight - standardHeight) * nextItemPercentageOffset, 0)
            attributes.height = newHeight
            
            if collectionView!.contentOffset.y > 0 {
                let scale = max(1 - pow(nextItemPercentageOffset, 2), 0.9)
//                attributes.transform3D = CATransform3DMakeScale(scale, scale, 1.0)
                attributes.transform = CGAffineTransformMakeScale(scale, scale)
            }
            
        } else if indexPath.item == (featuredItemIndex + 1) && indexPath.item != numberOfItems {
            let maxY = y + standardHeight
            height = standardHeight + max((featuredHeight - standardHeight) * nextItemPercentageOffset, 0)
            y = maxY - height
            
        } /*else {
            attributes.alpha = 0.0
        }*/
        
        // Lastly, the loop sets some common elements for each cell, including creating the right frame based upon the if condition above, setting the attributes to what was just calculated, and updating the cache values. The very last step is to update y so that it's at the bottom of the last calculated cell, so you can move down the list of cells efficiently.
        frame = CGRect(x: 0, y: y, width: width, height: height)
        attributes.frame = frame
        cache.append(attributes)
        y = CGRectGetMaxY(frame)
    }
    
  }
  
    /* Return all attributes in the cache whose frame intersects with the rect passed to the method */
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes = [CustomLayoutAttributes]()
        
        for attributes in cache {
            if CGRectIntersectsRect(attributes.frame, rect) {
                layoutAttributes.append(attributes)
            }
        }
        return layoutAttributes
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        let layoutAttributes = cache[indexPath.item]
        
        return layoutAttributes
    }
    
    override class func layoutAttributesClass() -> AnyClass {
        return CustomLayoutAttributes.self
    }
  
    /* Return true so that the layout is continuously invalidated as the user scrolls */
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return true
    }
    
    override func targetContentOffsetForProposedContentOffset(proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        print("Velocity: \(velocity)")
        
        let itemIndex = round(proposedContentOffset.y / dragOffset)
        var yOffset = itemIndex * dragOffset
        
        if velocity.y > 0.0 {
            yOffset = CGFloat(featuredItemIndex + 1) * dragOffset
            
        } else if velocity.y < -0.0 {
            yOffset = CGFloat(featuredItemIndex) * dragOffset
        }
        
        return CGPoint(x: 0, y: yOffset)
    }
  
}
