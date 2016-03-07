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
    
    let lightGrayTransparent = UIColor(hexString: "#F2F2F2")
//    let darkGrayTransparent = UIColor(red: 85/255, green: 85/255, blue: 85/255, alpha: 1.0)
    let darkGrayTransparent = UIColor(white: 0.8, alpha: 1.0)

    @IBInspectable var fillColor: UIColor!
    
    override func drawRect(rect: CGRect) {
        let path = UIBezierPath(ovalInRect: rect)
        
        // Add fill
        fillColor.setFill()
        path.fill()
        
        // Add shadow
        layer.shadowColor = UIColor(hexString: "#B9B9B9")?.CGColor
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
