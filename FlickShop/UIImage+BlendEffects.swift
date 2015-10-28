//
//  UIImage+BlendEffects.swift
//  FlickShop
//
//  Created by Ashish Kayastha on 10/25/15.
//  Copyright © 2015 Ashish Kayastha. All rights reserved.
//

import UIKit

extension UIImage {
    
//    func blendImageWithColor(color: UIColor, blendMode: CGBlendMode) -> UIImage {
//        UIGraphicsBeginImageContextWithOptions(size, true, 0)
//        color.setFill()
//        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
//        UIRectFill(rect)
//        drawInRect(rect, blendMode: blendMode, alpha: 1.0)
//        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        
//        return finalImage
//    }
    
    func blendImageWithColor(color: UIColor, blendMode: CGBlendMode) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        UIGraphicsBeginImageContextWithOptions(size, true, 0)
        let context = UIGraphicsGetCurrentContext()
        
        // fill the background with color so that translucent colors get lighter
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, rect)
        
        drawInRect(rect, blendMode: blendMode, alpha: 1.0)
        
        // grab the finished image and return it
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return finalImage
    }
}
