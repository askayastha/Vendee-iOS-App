//
//  ContainerProductDetailsViewController.swift
//  Vendee
//
//  Created by Ashish Kayastha on 1/16/16.
//  Copyright © 2016 Ashish Kayastha. All rights reserved.
//

import UIKit
import Crashlytics
import FirebaseAnalytics

class ContainerProductDetailsViewController: UIViewController {
    
    var productCategory: String!
    var product: Product!
    var productDetailsVC: ProductDetailsViewController?
    var didScrollCount: Int = 0
    
    @IBOutlet weak var backButton: FloatingButton!
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.setNavigationBarHidden(true, animated: false)
        
        // Log screen views
        GoogleAnalytics.trackScreenForName("Product Details View")
        FIRAnalytics.logEventWithName("Product_Details_View", parameters: nil)
        Answers.logCustomEventWithName("Product Details View", customAttributes: nil)
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
        if segue.identifier == "EmbedDetails" {
            productDetailsVC = segue.destinationViewController as? ProductDetailsViewController
            productDetailsVC?.delegate = self
            productDetailsVC?.product = product
        }
    }

}

extension ContainerProductDetailsViewController: ScrollEventsDelegate {
    
    func didScroll() {
//        didScrollCount++
//
//        if didScrollCount > 5 {
//            UIView.animateWithDuration(0.2) {
//                self.backButton.alpha = 0.0
//            }
//        }
    }
    
    func didEndDecelerating() {
//        UIView.animateWithDuration(0.2) {
//            self.backButton.alpha = 1.0
//        }
    }
}
