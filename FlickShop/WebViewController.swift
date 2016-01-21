//
//  WebViewController.swift
//  FlickShop
//
//  Created by Ashish Kayastha on 1/21/16.
//  Copyright © 2016 Ashish Kayastha. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    
    var url: NSURL!
    private var webView: WKWebView
    private var spinner: UIActivityIndicatorView!
    
    @IBOutlet weak var window: UIView!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var forwardButton: UIBarButtonItem!
    @IBOutlet weak var reloadButton: UIBarButtonItem!
    
    required init?(coder aDecoder: NSCoder) {
        webView = WKWebView(frame: CGRect.zero)
        spinner = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        spinner.color = UIColor(white: 0.1, alpha: 0.5)
        super.init(coder: aDecoder)
    }
    
    deinit {
        webView.removeObserver(self, forKeyPath: "loading")
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
        webView.stopLoading()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        backButton.enabled = false
        forwardButton.enabled = false
        
        webView.addSubview(spinner)
        window.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        spinner.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activateConstraints([
            NSLayoutConstraint.constraintsWithVisualFormat(
                "H:|[webView]|",
                options: [],
                metrics: nil,
                views: ["webView": webView]),
            NSLayoutConstraint.constraintsWithVisualFormat(
                "V:|[webView]|",
                options: [],
                metrics: nil,
                views: ["webView": webView])
            ].flatten().map{$0})
        
        NSLayoutConstraint.activateConstraints([
            spinner.centerXAnchor.constraintEqualToAnchor(webView.centerXAnchor),
            spinner.centerYAnchor.constraintEqualToAnchor(webView.centerYAnchor)
            ])
//        webView.addConstraints([
//            NSLayoutConstraint(item: spinner, attribute: .CenterX, relatedBy: .Equal, toItem: webView, attribute: .CenterX, multiplier: 1, constant: 0),
//            NSLayoutConstraint(item: spinner, attribute: .CenterY, relatedBy: .Equal, toItem: webView, attribute: .CenterY, multiplier: 1, constant: 0)
//            ])
        
        webView.addObserver(self, forKeyPath: "loading", options: .New, context: nil)
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .New, context: nil)
        webView.loadRequest(NSURLRequest(URL: url))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButtonPressed(sender: UIBarButtonItem) {
        webView.goBack()
    }
    
    @IBAction func forwardButtonPressed(sender: UIBarButtonItem) {
        webView.goForward()
    }
    
    @IBAction func reloadButtonPressed(sender: UIBarButtonItem) {
        webView.loadRequest(NSURLRequest(URL: url))
    }
    
    // MARK: - Key Value Observer
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        if keyPath == "loading" {
            backButton.enabled = webView.canGoBack
            forwardButton.enabled = webView.canGoForward
            
            guard let change = change else { return }
            if let val = change[NSKeyValueChangeNewKey] as? Bool {
                if val {
                    spinner.startAnimating()
                } else {
                    spinner.stopAnimating()
                }
            }
        } else if keyPath == "estimatedProgress" {
            print("Estimated Progress: \(webView.estimatedProgress)")
        }
    }

}
