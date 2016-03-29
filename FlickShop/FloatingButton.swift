//
//  FloatingButton.swift
//  Vendee
//
//  Created by Ashish Kayastha on 12/4/15.
//  Copyright © 2015 Ashish Kayastha. All rights reserved.
//

import UIKit

@IBDesignable
class FloatingButton: UIButton {
    
    var lightGray = UIColor(hexString: "#F2F2F2")
    let darkGray = UIColor(white: 0.8, alpha: 1.0)
    let borderColor = UIColor(hexString: "#B9B9B9")

    var fillColor: UIColor! = UIColor(hexString: "#F2F2F2")
    
    override func drawRect(rect: CGRect) {
        let path = UIBezierPath(ovalInRect: rect)
        
        // Add fill
        fillColor.setFill()
        path.fill()
        
        // Add border
        layer.cornerRadius = bounds.size.width / 2
        layer.borderWidth = 1.0
        layer.borderColor = borderColor?.CGColor
        
        // Add shadow
        layer.shadowColor = borderColor?.CGColor
        layer.shadowOffset = CGSizeMake(0, 0)
        layer.shadowOpacity = 1.0
        layer.shadowRadius = 6/7
        layer.shadowPath = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: bounds.size.width / 2
            ).CGPath
        
        // Add border shadow
//        let shadowPathWidth: CGFloat = 1.0
//        let layerAndShadowRadius = layer.cornerRadius
//        layer.shadowPath = CGPathCreateCopyByStrokingPath(CGPathCreateWithRoundedRect(bounds, layerAndShadowRadius, layerAndShadowRadius, nil), nil, shadowPathWidth, .Round, .Bevel, 0.0)
    }
    
    override var highlighted: Bool {
        
        didSet {
            fillColor = highlighted ? darkGray : lightGray
            setNeedsDisplay()
        }
    }

}
