//
//  InfoButton.swift
//  Vendee
//
//  Created by Ashish Kayastha on 1/16/16.
//  Copyright © 2016 Ashish Kayastha. All rights reserved.
//

import UIKit

@IBDesignable
class InfoButton: UIButton {
    
    let lightGrayTransparent = UIColor(hexString: "#F2F2F2", alpha: 0.5)
    let darkGrayTransparent = UIColor(white: 0.3, alpha: 0.5)

    @IBInspectable var fillColor: UIColor!
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        let path = UIBezierPath(roundedRect: rect, cornerRadius: 5.0)
        fillColor.setFill()
        path.fill()
    }
    
    override var highlighted: Bool {
        
        didSet {
            fillColor = highlighted ? darkGrayTransparent : lightGrayTransparent
            setNeedsDisplay()
        }
    }

}
