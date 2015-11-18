//
//  ContainerBrowseViewController.swift
//  FlickShop
//
//  Created by Ashish Kayastha on 11/8/15.
//  Copyright © 2015 Ashish Kayastha. All rights reserved.
//

import UIKit

class ContainerBrowseViewController: UIViewController, UICollectionViewDelegate {
    
    var productCategory: String!
    var brands: [Brand]!
    var didScrollCount = 0
    
    @IBOutlet weak var backButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        view.layer.cornerRadius = 5.0
//        view.layer.masksToBounds = true
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        backButton.alpha = 1.0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButtonTapped(sender: UIButton) {
        navigationController?.popViewControllerAnimated(true)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowBrowseCategory" {
            let controller = segue.destinationViewController as! BrowseCollectionViewController
            
            controller.delegate = self
            controller.productCategory = productCategory
            controller.brands = brands
        }
    }

}

extension ContainerBrowseViewController: ScrollEventsDelegate {
    
    func didScroll() {
        didScrollCount++
        
        if didScrollCount > 5 {
            UIView.animateWithDuration(0.2) {
                self.backButton.alpha = 0.0
            }
        }
    }
    
    func didEndDecelerating() {
        UIView.animateWithDuration(0.2) {
            self.backButton.alpha = 1.0
        }
    }
}