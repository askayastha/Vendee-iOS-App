//
//  SlideOutAnimationController.swift
//  FlickShop
//
//  Created by Ashish Kayastha on 1/27/16.
//  Copyright © 2016 Ashish Kayastha. All rights reserved.
//

import UIKit

class SlideOutAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.5
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        if let fromView = transitionContext.viewForKey(UITransitionContextFromViewKey),
            let containerView = transitionContext.containerView() {
                
                let duration = transitionDuration(transitionContext)
                UIView.animateWithDuration(duration, animations: {
                    fromView.center.y += containerView.bounds.size.height
                    }, completion: { finished in
                        transitionContext.completeTransition(finished)
                })
        }
    }
}