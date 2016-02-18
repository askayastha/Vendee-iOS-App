//
//  CategoriesLayout.swift
//  Vendee
//
//  Created by Ashish Kayastha on 10/30/15.
//  Copyright © 2015 Ashish Kayastha. All rights reserved.
//

import UIKit

class CategoriesLayout: UICollectionViewFlowLayout {
    
    private let cellWidth: CGFloat = 200
    private let cellHeight: CGFloat = 270
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        scrollDirection = UICollectionViewScrollDirection.Horizontal
        itemSize = CGSizeMake(cellWidth, cellHeight)
//        minimumLineSpacing = 10.0
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        
        //2
        collectionView?.contentInset = UIEdgeInsets(
            top: 0,
            left: (collectionView!.bounds.width - cellWidth) / 2,
            bottom: 0,
            right: (collectionView!.bounds.width - cellWidth) / 2
        )
    }

    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        //1
        let attributes = super.layoutAttributesForElementsInRect(rect) as [UICollectionViewLayoutAttributes]!
        var attributesCopy = [UICollectionViewLayoutAttributes]()
        
        //2
        for itemAttributes in attributes {
            let itemAttributesCopy = itemAttributes.copy() as! UICollectionViewLayoutAttributes
            //3
            let frame = itemAttributesCopy.frame
            //4
            let distance = abs(collectionView!.contentOffset.x + collectionView!.contentInset.left - frame.origin.x)
            //5
            let scale = min(max(1 - distance / (collectionView!.bounds.width), 0.75), 1)
            //6
            itemAttributesCopy.transform = CGAffineTransformMakeScale(scale, scale)
            
            attributesCopy.append(itemAttributesCopy)
        }
        
        return attributesCopy
    }
    
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return true
    }
    
    override func targetContentOffsetForProposedContentOffset(proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        // Snap cells to centre
        //1
        var newOffset = CGPoint()
        //2
        let layout = collectionView!.collectionViewLayout as! UICollectionViewFlowLayout
        //3
        let width = layout.itemSize.width + layout.minimumLineSpacing
        //4
        var offset = proposedContentOffset.x + collectionView!.contentInset.left
        
        //5
        if velocity.x > 0 {
            //ceil returns next biggest number
            offset = width * ceil(offset / width)
        }
        //6
        if velocity.x == 0 {
            //rounds the argument
            offset = width * round(offset / width)
        }
        //7
        if velocity.x < 0 {
            //removes decimal part of argument
            offset = width * floor(offset / width)
        }
        //8
        newOffset.x = offset - collectionView!.contentInset.left
        newOffset.y = proposedContentOffset.y //y will always be the same...
        return newOffset
    }
}
