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
    var didScrollCount: Int = 0
    var browseViewController: BrowseViewController?
    var buttonsHidden = false
    lazy private var spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        spinner.color = UIColor(white: 0.1, alpha: 0.5)
        spinner.startAnimating()
        
        return spinner
    }()
    
    @IBOutlet weak var backButton: FloatingButton!
    @IBOutlet weak var filterButton: FloatingButton!
    
    deinit {
        print("Deallocating ContainerBrowseViewController !!!!!!!!!!!!!!!")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        // Spinner setup
        spinner.center = CGPoint(x: view.center.x, y: view.center.y)
        view.addSubview(spinner)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if buttonsHidden {
            backButton.alpha = 1.0
            filterButton.alpha = 1.0
            backButton.transform = CGAffineTransformIdentity
            filterButton.transform = CGAffineTransformIdentity
        }
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
        
        if segue.identifier == "EmbedBrowseCategory" {
            browseViewController = segue.destinationViewController as? BrowseViewController
            
            browseViewController?.delegate = self
            browseViewController?.productCategory = productCategory
            browseViewController?.hideSpinner = {
                if self.spinner.isAnimating() {
                    self.spinner.stopAnimating()
                }
            }
        }
    }
}

extension ContainerBrowseViewController: SwipeDelegate {
    
    func swipedUp() {
        if buttonsHidden { return }
        
        // Hide button with animation
        UIView.animateWithDuration(0.3, animations: {
            self.backButton.transform = CGAffineTransformMakeScale(0.1, 0.1)
            self.filterButton.transform = CGAffineTransformMakeScale(0.1, 0.1)
            self.backButton.alpha = 0.0
            self.filterButton.alpha = 0.0
            }, completion: { _ in
                self.buttonsHidden = true
        })
    }
    
    func swipedDown() {
        if !buttonsHidden { return }
        
        // Show button with animation
        UIView.animateWithDuration(0.3, animations: {
            self.backButton.transform = CGAffineTransformIdentity
            self.filterButton.transform = CGAffineTransformIdentity
            self.backButton.alpha = 1.0
            self.filterButton.alpha = 1.0
            }, completion: { _ in
                self.buttonsHidden = false
        })
    }
}