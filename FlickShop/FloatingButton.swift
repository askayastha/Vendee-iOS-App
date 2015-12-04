//
//  BackButton.swift
//  FlickShop
//
//  Created by Ashish Kayastha on 12/4/15.
//  Copyright © 2015 Ashish Kayastha. All rights reserved.
//

import UIKit

@IBDesignable
class FloatingButton: UIButton {
    
//    let brightOrange = UIColor(red: 255/255, green: 168/255, blue: 0, alpha: 1.0)

    @IBInspectable var fillColor: UIColor!
    
    override func drawRect(rect: CGRect) {
        // Add fill
        let path = UIBezierPath(ovalInRect: rect)
        fillColor.setFill()
        path.fill()
        
        // Add shadow
        layer.shadowColor = UIColor.lightGrayColor().CGColor
        layer.shadowOffset = CGSizeMake(0, 2)
        layer.shadowOpacity = 1.0
        layer.shadowRadius = 3.0
        layer.shadowPath = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: bounds.size.width / 2
            ).CGPath
    }
    
    override var highlighted: Bool {
        
        didSet {
            fillColor = highlighted ? UIColor.lightGrayColor() : UIColor.darkGrayColor()
            setNeedsDisplay()
        }
    }

}
