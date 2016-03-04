//
//  ContainerBrowseViewController.swift
//  Vendee
//
//  Created by Ashish Kayastha on 11/8/15.
//  Copyright © 2015 Ashish Kayastha. All rights reserved.
//

import UIKit

class ContainerBrowseViewController: UIViewController {
    
    var productCategory: String!
    var didScrollCount: Int = 0
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
        
        Google.sendAnalyticsForScreenView("Browse View")
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        // Spinner setup
        view.addSubview(spinner)
        
        spinner.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activateConstraints([
            spinner.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor),
            spinner.centerYAnchor.constraintEqualToAnchor(view.centerYAnchor)
            ])
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
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "EmbedBrowseCategory" {
            let browseViewController = segue.destinationViewController as? BrowseViewController
            
            browseViewController?.delegate = self
            browseViewController?.productCategory = productCategory
            
            browseViewController?.animateSpinner = { [unowned self] animate in
                if animate {
                    self.spinner.startAnimating()
                    UIView.animateWithDuration(0.3, animations: {
                        self.spinner.transform = CGAffineTransformIdentity
                        self.spinner.alpha = 1.0
                        }, completion: nil)
                    
                } else {
                    UIView.animateWithDuration(0.3, animations: {
                        self.spinner.transform = CGAffineTransformMakeScale(0.1, 0.1)
                        self.spinner.alpha = 0.0
                        }, completion: { _ in
                            self.spinner.stopAnimating()
                    })
                }
            }
        }
    }
    
    // MARK: - Helper methods
    
    private func setTabBarVisible(visible: Bool, animated: Bool) {
        if isToolBarVisible() == visible { return }
        
        let tabBar = navigationController?.tabBarController?.tabBar
        let frame = tabBar!.frame
        let height = frame.size.height
        let offsetY = visible ? -height : height
        
        UIView.animateWithDuration(animated ? 0.3 : 0.0) {
            tabBar!.frame = CGRectOffset(frame, 0, offsetY)
        }
    }
    
    private func isToolBarVisible() -> Bool {
        let tabBar = navigationController?.tabBarController?.tabBar
        return tabBar!.frame.origin.y < CGRectGetMaxY(view.frame)
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
//        setTabBarVisible(false, animated: true)
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
//        setTabBarVisible(true, animated: true)
    }
}