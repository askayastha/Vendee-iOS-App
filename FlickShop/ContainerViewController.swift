//
//  ContainerViewController.swift
//  FlickShop
//
//  Created by Ashish Kayastha on 11/22/15.
//  Copyright © 2015 Ashish Kayastha. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController {
    
    private let categoryIdentifier = "EmbedCategory"
    private let brandIdentifier = "EmbedBrand"

    override func viewDidLoad() {
        super.viewDidLoad()

        performSegueWithIdentifier(categoryIdentifier, sender: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        // If we're going to the first view controller.
        if segue.identifier == categoryIdentifier {
            // If this is not the first time we're loading this.
            if childViewControllers.count > 0 {
                swapFromViewController(childViewControllers.first!, toViewController: segue.destinationViewController)
            } else {
                // If this is the very first time we're loading this, we need to do an initial load and not a swap.
                addChildViewController(segue.destinationViewController)
                let destinationView = segue.destinationViewController.view
                
                destinationView.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)
                view.addSubview(destinationView)
                segue.destinationViewController.didMoveToParentViewController(self)
            }
        } else {
            swapFromViewController(childViewControllers.first!, toViewController: segue.destinationViewController)
        }
    }
    
    func swapFromViewController(fromViewController: UIViewController, toViewController: UIViewController) {
        
        toViewController.view.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)
        
        fromViewController.willMoveToParentViewController(nil)
        addChildViewController(toViewController)
        
        transitionFromViewController(fromViewController, toViewController: toViewController, duration: 0.2, options: .TransitionCrossDissolve, animations: nil, completion: { _ in
            fromViewController.removeFromParentViewController()
            toViewController.didMoveToParentViewController(self)
        })
    }
    
    func switchViewControllerForIdentifier(identifier: String) {
        
        performSegueWithIdentifier(identifier, sender: self)
    }

}
