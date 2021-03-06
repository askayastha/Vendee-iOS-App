//
//  ContainerBrowseViewController.swift
//  Vendee
//
//  Created by Ashish Kayastha on 11/8/15.
//  Copyright © 2015 Ashish Kayastha. All rights reserved.
//

import UIKit
import Crashlytics
import FirebaseAnalytics

class ContainerBrowseViewController: UIViewController {
    
    var productCategory: String!
    var searchText: String!
    var didScrollCount: Int = 0
    var buttonsHidden = false
    
    let filtersModel: FiltersModel
    
    lazy private var spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        spinner.color = UIColor(white: 0.1, alpha: 0.5)
        spinner.startAnimating()
        
        return spinner
    }()
    
    @IBOutlet weak var backButton: FloatingButton!
    @IBOutlet weak var filterButton: FloatingButton!
    
    deinit {
        print("Deallocating ContainerBrowseViewController!")
    }
    
    required init?(coder aDecoder: NSCoder) {
        filtersModel = (App.selectedTab == .Search) ? SearchFiltersModel.sharedInstance() : FiltersModel.sharedInstance()
        
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        automaticallyAdjustsScrollViewInsets = false
        
        // Spinner setup
        view.addSubview(spinner)
        
        spinner.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activateConstraints([
            spinner.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor),
            spinner.centerYAnchor.constraintEqualToAnchor(view.centerYAnchor)
            ])
        
        // Log screen views
        GoogleAnalytics.trackScreenForName("Browse View")
        FIRAnalytics.logEventWithName("Browse_View", parameters: nil)
        Answers.logCustomEventWithName("Browse View", customAttributes: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if buttonsHidden {
            backButton.alpha = 1.0
            filterButton.alpha = 1.0
            backButton.transform = CGAffineTransformIdentity
            filterButton.transform = CGAffineTransformIdentity
        }
        
        if filtersModel.filtersApplied {
            filterButton.setImage(UIImage(named: "filter_selected"), forState: .Normal)
//            filterButton.imageView?.tintImageColor(UIColor.vendeeColor())
        } else {
            filterButton.setImage(UIImage(named: "filter_medium_gray"), forState: .Normal)
//            filterButton.imageView?.tintImageColor(UIColor(hexString: "#696771")!)
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
            browseViewController?.searchText = searchText
            
            browseViewController?.animateSpinner = { [weak self] animate in
                guard let strongSelf = self else { return }
                if animate {
                    strongSelf.spinner.startAnimating()
                    UIView.animateWithDuration(0.3, animations: {
                        strongSelf.spinner.transform = CGAffineTransformIdentity
                        strongSelf.spinner.alpha = 1.0
                        }, completion: nil)
                    
                } else {
                    UIView.animateWithDuration(0.3, animations: {
                        strongSelf.spinner.transform = CGAffineTransformMakeScale(0.1, 0.1)
                        strongSelf.spinner.alpha = 0.0
                        }, completion: { _ in
                            strongSelf.spinner.stopAnimating()
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