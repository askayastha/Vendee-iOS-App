//
//  SlideInAnimationController.swift
//  Vendee
//
//  Created by Ashish Kayastha on 1/28/16.
//  Copyright © 2016 Ashish Kayastha. All rights reserved.
//

import UIKit

class SlideInAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.5
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        if let toView = transitionContext.viewForKey(UITransitionContextToViewKey),
            let containerView = transitionContext.containerView() {
                toView.center.y -= containerView.bounds.size.height
                
//                var perspective = CATransform3DIdentity
//                perspective.m34 = -1.0/500
//
//                let rotationTransform = CATransform3DRotate(perspective, CGFloat(M_PI_4/2), -1, 0, 0)
//                toView.layer.transform = rotationTransform
                
                containerView.addSubview(toView)
                let duration = transitionDuration(transitionContext)
                
                UIView.animateWithDuration(duration, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.0, options: [], animations: {
                    toView.center.y += containerView.bounds.size.height
//                    toView.layer.transform = CATransform3DIdentity
                    
                    }, completion: { finished in
                        transitionContext.completeTransition(finished)
                })
                
        }
    }
}