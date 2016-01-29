//
//  ContainerWebViewController.swift
//  FlickShop
//
//  Created by Ashish Kayastha on 1/21/16.
//  Copyright © 2016 Ashish Kayastha. All rights reserved.
//

import UIKit

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
        print("Deallocating FlickViewController !!!!!!!!!!!!!!!")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Spinner setup
        spinner.center = CGPoint(x: view.center.x, y: view.center.y)
        view.addSubview(spinner)
        
//        spinner.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activateConstraints([
//            spinner.centerXAnchor.constraintEqualToAnchor(webView.centerXAnchor),
//            spinner.centerYAnchor.constraintEqualToAnchor(webView.centerYAnchor)
//            ])
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Start NSUserActivity
        let activity = NSUserActivity(activityType: "com.ashish.flickshop.webview")
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
                } else {
                    strongSelf.spinner.stopAnimating()
                }
            }
            webViewController?.showPopup = { [weak self] in
                guard let strongSelf = self else { return }
                guard strongSelf.showPopup else { return }
                
                if let priceDetailsVC = strongSelf.storyboard!.instantiateViewControllerWithIdentifier("PriceDetailsViewController") as? PriceDetailsViewController {
                    priceDetailsVC.product = strongSelf.product
                    strongSelf.presentViewController(priceDetailsVC, animated: true, completion: nil)
                    strongSelf.showPopup = false
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
