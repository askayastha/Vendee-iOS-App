//
//  ContainerFlickViewController.swift
//  Vendee
//
//  Created by Ashish Kayastha on 11/18/15.
//  Copyright © 2015 Ashish Kayastha. All rights reserved.
//

import UIKit
import Crashlytics
import FirebaseAnalytics

class ContainerFlickViewController: UIViewController {
    
    var search: Search!
    var indexPath: NSIndexPath?
    var productCategory: String!
    var searchText: String!
    var didScrollCount: Int = 0
    var flickViewController: FlickViewController?
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var infoButton: UIButton!
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        // Log screen views
        GoogleAnalytics.trackScreenForName("Flick View")
        FIRAnalytics.logEventWithName("Flick_View", parameters: nil)
        Answers.logCustomEventWithName("Flick View", customAttributes: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        view.layoutIfNeeded()
        
        didScrollCount = 0
        backButton.alpha = 1.0
        infoButton.alpha = 1.0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButtonTapped(sender: UIButton) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func infoButtonTapped(sender: UIButton) {
        flickViewController?.openDetailsForProduct()
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EmbedFlickCategory" {
            flickViewController = segue.destinationViewController as? FlickViewController
            
            flickViewController?.delegate = self
            flickViewController?.search = search
            flickViewController?.indexPath = indexPath
            flickViewController?.productCategory = productCategory
            flickViewController?.searchText = searchText
        }
    }

}

extension ContainerFlickViewController: ScrollEventsDelegate {
    
    func didScroll() {
        didScrollCount += 1
        
        if didScrollCount > 5 {
            UIView.animateWithDuration(0.3) {
//                self.backButton.transform = CGAffineTransformMakeScale(0.1, 0.1)
//                self.infoButton.transform = CGAffineTransformMakeScale(0.1, 0.1)
                self.backButton.alpha = 0.0
                self.infoButton.alpha = 0.0
            }
        }
    }
    
    func didEndDecelerating() {
        UIView.animateWithDuration(0.3) {
//            self.backButton.transform = CGAffineTransformIdentity
//            self.infoButton.transform = CGAffineTransformIdentity
            self.backButton.alpha = 1.0
            self.infoButton.alpha = 1.0
        }
    }
}
