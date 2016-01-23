//
//  TwoColumnLayout.swift
//  FlickShop
//
//  Created by Ashish Kayastha on 10/9/15.
//  Copyright © 2015 Ashish Kayastha. All rights reserved.
//

import UIKit

protocol TwoColumnLayoutDelegate: class {
    func collectionView(collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: NSIndexPath, withWidth width: CGFloat) -> CGFloat
}

class TwoColumnLayoutAttributes: UICollectionViewLayoutAttributes {
    
    // This declares the photoHeight property that the cell will use to resize its image view.
    var photoHeight: CGFloat = 0.0
    
    // This overrides copyWithZone(). Subclasses of UICollectionViewLayoutAttributes need to conform to thte NSCopying protocol because the attribute's objects can be copied internally. You override this method to guarantee that the photoHeight property is set when the object is copied.
    override func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = super.copyWithZone(zone) as! TwoColumnLayoutAttributes
        copy.photoHeight = photoHeight
        return copy
    }
    
    // This overrides isEqual(_:) and it's mandatory as well. The collection view determines whether the attributes have changed by comparing the old and new attribute objects using isEqual(_:). You must implement it to compare the custom properties of your subclass. The code compares the photoHeight of both instances, and if they are equal, calls super to determine if the inherited attributes are the same. If the photo heights are different, it returns false.
    override func isEqual(object: AnyObject?) -> Bool {
        if let attributes = object as? TwoColumnLayoutAttributes {
            if attributes.photoHeight == photoHeight {
                return super.isEqual(object)
            }
        }
        
        return false
    }
}

class TwoColumnLayout: UICollectionViewLayout {
    // This keeps a reference to the delegate
    weak var delegate: TwoColumnLayoutDelegate!
    
    // These are two public properties for configuring the layout: the nunmber of columns and the cell padding.
    var numberOfColumns = 2
    var cellPadding: CGFloat = 4.0
    let brandPriceHeight: CGFloat = 40.0
    let verticalPadding: CGFloat = 5.0
    let bottomPadding: CGFloat = 3.0
    
    // This is an array to cache the calculated attributes. When you call prepareLayout(), you'll calculate the attributes for all items and add them to the cache. When the collection view later requests the layout attributes, you can be efficient and query the cache instead of recalculating them every time.
    private var cache = [TwoColumnLayoutAttributes]()
    
    // This declares two properties to store the content size. contentHeight is incremented as photos are added, and contentWidth is calculated based on the collection view width and its content inset.
    private var contentHeight: CGFloat = 0.0
    private var contentWidth: CGFloat {
        let insets = collectionView!.contentInset
        
        return CGRectGetWidth(collectionView!.bounds) - (insets.left + insets.right)
    }
    
    override func prepareLayout() {
        cache.removeAll(keepCapacity: false)
        
        // You only calculate the layout attributes if cache is empty.
        if cache.isEmpty {
            // This declares and fills the xOffset array with the x-coordinate for every column based on the column widths. The yOffset array tracks the y-position for every column. You initialize each value in yOffset to 0, since this is the offset of the first item in each column.
            let columnWidth = contentWidth / CGFloat(numberOfColumns)
            var xOffset = [CGFloat]()
            
            for column in 0..<numberOfColumns {
                xOffset.append(CGFloat(column) * columnWidth)
            }
            
            var column = 0
            var yOffset = [CGFloat](count: numberOfColumns, repeatedValue: 0)
            
            // This loops through all the items in the first section, as this particular layout has only one section.
            for item in 0..<collectionView!.numberOfItemsInSection(0) {
                
                let indexPath = NSIndexPath(forItem: item, inSection: 0)
                
                // This is where you perform the frame calculation. width is the previously calculated cellWidth, with the padding between cells removed. You ask the delegate for the height of the image and the annotation, and calculate the frame height based on those heights and the predefined cellPadding for the top and bottom. You then combine this with the x and y offsets of the current column to create the insetFrame used by the attribute.
                let width = columnWidth - cellPadding * 2
                var photoHeight = delegate.collectionView(collectionView!, heightForPhotoAtIndexPath: indexPath, withWidth: width)
                photoHeight = min(300.0, photoHeight)
                let height = verticalPadding + brandPriceHeight + verticalPadding + photoHeight + verticalPadding + bottomPadding
                let frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: height)
                let insetFrame = CGRectInset(frame, cellPadding, cellPadding)
                
                // This creates an instance of UICollectionViewLayoutAtrribute, sets its frame using insetFrame and appends the attributes to cache.
                let attributes = TwoColumnLayoutAttributes(forCellWithIndexPath: indexPath)
                attributes.photoHeight = photoHeight
                attributes.frame = insetFrame
                cache.append(attributes)
                
                // This expands contentHeight to account for the frame of the newly calculated item. It then advances the yOffset for the current column based on the frame. Finally, it advances the column so that the next item will be placed in the next column.
                contentHeight = max(contentHeight, CGRectGetMaxY(frame))
//                print(photoHeight)
                yOffset[column] = yOffset[column] + height
                
                column = column >= (numberOfColumns - 1) ? 0 : ++column
            }
        }
    }
    
    override func collectionViewContentSize() -> CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        var layoutAttribtes = [UICollectionViewLayoutAttributes]()
        
        for attributes in cache {
            if CGRectIntersectsRect(attributes.frame, rect) {
                layoutAttribtes.append(attributes)
            }
        }
        
        return layoutAttribtes
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        let layoutAttributes = cache[indexPath.item]
        
        return layoutAttributes
    }
    
    override class func layoutAttributesClass() -> AnyClass {
        return TwoColumnLayoutAttributes.self
    }
}
