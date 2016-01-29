//
//  PopAnimationController.swift
//  FlickShop
//
//  Created by Ashish Kayastha on 1/29/16.
//  Copyright © 2016 Ashish Kayastha. All rights reserved.
//

import UIKit

class PopAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    let duration = 1.0
    var presenting = true
    var originFrame = CGRect.zero
    var initialBoundingFrame = CGRect.zero
    var finalBoundingFrame = CGRect.zero
    var dismissCompletion: (()->())?
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return duration
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView()!
        let toView = transitionContext.viewForKey(UITransitionContextToViewKey)!
        let photosView = presenting ? toView : transitionContext.viewForKey(UITransitionContextFromViewKey)!
        
        let initialFrame = presenting ? originFrame : photosView.frame
        let finalFrame = presenting ? photosView.frame : originFrame
        
        let xScaleFactor = presenting ?
            initialBoundingFrame.width / finalBoundingFrame.width :
            finalFrame.width / initialFrame.width
        
        let yScaleFactor = presenting ?
            initialBoundingFrame.height / finalBoundingFrame.height :
            finalFrame.height / initialFrame.height
        
        let scaleTransform = CGAffineTransformMakeScale(xScaleFactor, yScaleFactor)
        
        if presenting {
            photosView.transform = scaleTransform
            photosView.center = CGPoint(
                x: CGRectGetMidX(initialFrame),
                y: CGRectGetMidY(initialFrame))
        }
        
        containerView.addSubview(toView)
        containerView.bringSubviewToFront(photosView)
        
        UIView.animateWithDuration(duration, delay:0.0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.0,
            options: [],
            animations: {
                if self.presenting {
                    photosView.transform = CGAffineTransformIdentity
                    photosView.center = CGPoint(x: CGRectGetMidX(finalFrame), y: CGRectGetMidY(finalFrame))
                }
                
            }, completion:{ _ in
                transitionContext.completeTransition(true)
        })
    }
    
}