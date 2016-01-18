//
//  ContainerProductDetailsViewController.swift
//  FlickShop
//
//  Created by Ashish Kayastha on 1/16/16.
//  Copyright © 2016 Ashish Kayastha. All rights reserved.
//

import UIKit

class ContainerProductDetailsViewController: UIViewController {
    
    var productCategory: String!
    var product: Product!
    var brands: [Brand]!
    var productDetailsVC: ProductDetailsViewController?
    var didScrollCount: Int = 0
    
    @IBOutlet weak var backButton: FloatingButton!
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    @IBAction func backButtonTapped(sender: UIButton) {
//        navigationController?.popViewControllerAnimated(true)
//    }
    
    @IBAction func closeButton() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EmbedDetails" {
            productDetailsVC = segue.destinationViewController as? ProductDetailsViewController
            productDetailsVC?.delegate = self
            productDetailsVC?.product = product
            productDetailsVC?.brands = brands
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
