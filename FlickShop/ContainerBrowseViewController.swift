//
//  ContainerBrowseViewController.swift
//  FlickShop
//
//  Created by Ashish Kayastha on 11/8/15.
//  Copyright © 2015 Ashish Kayastha. All rights reserved.
//

import UIKit

class ContainerBrowseViewController: UIViewController {
    
    var productCategory: String!
    var brands: [Brand]!
    var didScrollCount: Int = 0
    
    @IBOutlet weak var backButton: FloatingButton!
    @IBOutlet weak var filterButton: FloatingButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
//        didScrollCount = 0
//        backButton.alpha = 1.0
        backButton.adjustsImageWhenHighlighted = false
        filterButton.adjustsImageWhenHighlighted = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButtonTapped(sender: UIButton) {
        navigationController?.popViewControllerAnimated(true)
    }

//    @IBAction func filterButtonTapped(sender: UIButton) {
//        
//    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "EmbedBrowseCategory" {
            let controller = segue.destinationViewController as! BrowseViewController
            
            controller.delegate = self
            controller.productCategory = productCategory
            controller.brands = brands
        }
    }

}

extension ContainerBrowseViewController: ScrollEventsDelegate {
    
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