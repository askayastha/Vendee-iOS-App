//
//  ContainerWebViewController.swift
//  Vendee
//
//  Created by Ashish Kayastha on 1/21/16.
//  Copyright © 2016 Ashish Kayastha. All rights reserved.
//

import UIKit
import Crashlytics

class ContainerWebViewController: UIViewController {
    
    var webpageURL: NSURL!
    var product: Product!
    var webViewController: WebViewController?
    var backButtonHidden = false
    var showPopup = true
    lazy private var spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        spinner.color = UIColor(white: 0.1, alpha: 0.5)
        spinner.startAnimating()
        
        return spinner
    }()
    
    @IBOutlet weak var backButton: UIButton!
    
    deinit {
        print("Deallocating ContainerWebViewController!")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Spinner setup
        view.addSubview(spinner)
        
        spinner.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activateConstraints([
            spinner.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor),
            spinner.centerYAnchor.constraintEqualToAnchor(view.centerYAnchor)
            ])
        
        // Log screen views
        GoogleAnalytics.trackScreenForName("Web View")
        Answers.logCustomEventWithName("Web View", customAttributes: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Start NSUserActivity
        let activity = NSUserActivity(activityType: "com.askayastha.vendee.webview")
        activity.title = "View Shopping URL"
        activity.webpageURL = webpageURL
        userActivity = activity
        userActivity?.becomeCurrent()
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
        if segue.identifier == "EmbedWebView" {
            webViewController = segue.destinationViewController as? WebViewController
            webViewController?.webpageURL = webpageURL
            webViewController?.product = product
            webViewController?.delegate = self
            webViewController?.animateSpinner = { [weak self] animate in
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
            webViewController?.showPopup = { [unowned self] in
                guard self.showPopup else { return }
                
                if let priceDetailsVC = self.storyboard!.instantiateViewControllerWithIdentifier("PriceDetailsViewController") as? PriceDetailsViewController {
                    priceDetailsVC.product = self.product
                    self.presentViewController(priceDetailsVC, animated: true, completion: nil)
                    self.showPopup = false
                }
            }
        }
    }

}

extension ContainerWebViewController: SwipeDelegate {
    
    func swipedUp() {
        if backButtonHidden { return }
        
        // Hide button with animation
        UIView.animateWithDuration(0.3, animations: {
            self.backButton.transform = CGAffineTransformMakeScale(0.1, 0.1)
            self.backButton.alpha = 0.0
            }, completion: { _ in
                self.backButtonHidden = true
        })
    }
    
    func swipedDown() {
        if !backButtonHidden { return }
        
        // Show button with animation
        UIView.animateWithDuration(0.3, animations: {
            self.backButton.transform = CGAffineTransformIdentity
            self.backButton.alpha = 1.0
            }, completion: { _ in
                self.backButtonHidden = false
        })
    }
}
