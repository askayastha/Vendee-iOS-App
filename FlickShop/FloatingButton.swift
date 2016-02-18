//
//  BackButton.swift
//  Vendee
//
//  Created by Ashish Kayastha on 12/4/15.
//  Copyright © 2015 Ashish Kayastha. All rights reserved.
//

import UIKit

@IBDesignable
class FloatingButton: UIButton {
    
//    let brightOrange = UIColor(red: 255/255, green: 168/255, blue: 0, alpha: 1.0)
    let lightGrayTransparent = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1.0)
//    let darkGrayTransparent = UIColor(red: 85/255, green: 85/255, blue: 85/255, alpha: 1.0)
    let darkGrayTransparent = UIColor(white: 0.8, alpha: 1.0)

    @IBInspectable var fillColor: UIColor!
    
    override func drawRect(rect: CGRect) {
        let path = UIBezierPath(ovalInRect: rect)
        
        // Add fill
        fillColor.setFill()
        path.fill()
        
        // Add shadow
        layer.shadowColor = UIColor(red: 185/255, green: 185/255, blue: 185/255, alpha: 1.0).CGColor
        layer.shadowOffset = CGSizeMake(0, 0)
        layer.shadowOpacity = 1.0
        layer.shadowRadius = 6/7
        layer.shadowPath = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: bounds.size.width / 2
            ).CGPath
    }
    
    override var highlighted: Bool {
        
        didSet {
            fillColor = highlighted ? darkGrayTransparent : lightGrayTransparent
            setNeedsDisplay()
        }
    }

}
