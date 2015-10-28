//
//  CustomLayoutAttributes.swift
//  FlickShop
//
//  Created by Ashish Kayastha on 9/21/15.
//  Copyright (c) 2015 Ashish Kayastha. All rights reserved.
//

import UIKit

class CustomLayoutAttributes: UICollectionViewLayoutAttributes {
    
    var height: CGFloat = 0.0
    
    // MARK: NSCopying
    override func copyWithZone(zone: NSZone) -> AnyObject {
        
        let copy = super.copyWithZone(zone) as! CustomLayoutAttributes
        copy.height = self.height
        return copy
    }
    
    override func isEqual(object: AnyObject?) -> Bool {
        if let attributes = object as? CustomLayoutAttributes {
            if attributes.height == height {
                return super.isEqual(object)
            }
        }
        return false
    }
}
