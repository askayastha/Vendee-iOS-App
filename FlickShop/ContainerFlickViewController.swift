//
//  ContainerFlickViewController.swift
//  FlickShop
//
//  Created by Ashish Kayastha on 11/18/15.
//  Copyright © 2015 Ashish Kayastha. All rights reserved.
//

import UIKit

class ContainerFlickViewController: UIViewController {
    
    var search: Search!
    var indexPath: NSIndexPath?
    var brands: [Brand]!
    var productCategory: String!
    var didScrollCount: Int = 0
    
    @IBOutlet weak var backButton: UIButton!
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        view.layoutIfNeeded()
        
        didScrollCount = 0
        backButton.alpha = 1.0
        backButton.adjustsImageWhenHighlighted = false
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
        if segue.identifier == "EmbedFlickCategory" {
            let controller = segue.destinationViewController as! FlickViewController
            
            controller.delegate = self
            controller.search = search
            controller.indexPath = indexPath
            controller.brands = brands
            controller.productCategory = productCategory
        }
    }

}

extension ContainerFlickViewController: ScrollEventsDelegate {
    
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
