//
//  WebViewController.swift
//  Vendee
//
//  Created by Ashish Kayastha on 1/21/16.
//  Copyright © 2016 Ashish Kayastha. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController, WKNavigationDelegate {
    
    var webpageURL: NSURL!
    var product: Product!
    private var webView: WKWebView
    weak var delegate: SwipeDelegate?
    var animateSpinner: ((Bool)->())?
    var showPopup: (()->())?
    
    @IBOutlet weak var window: UIView!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var forwardButton: UIBarButtonItem!
    @IBOutlet weak var reloadButton: UIBarButtonItem!
    @IBOutlet weak var toolBar: UIToolbar!
    
    required init?(coder aDecoder: NSCoder) {
        let configuration = WKWebViewConfiguration()
        let hideForwardingScriptURL = NSBundle.mainBundle().pathForResource("hideForwarding", ofType: "js")
        let hideForwardingJS = try! String(contentsOfFile: hideForwardingScriptURL!, encoding: NSUTF8StringEncoding)
        let hideForwardingScript = WKUserScript(source: hideForwardingJS, injectionTime: .AtDocumentStart, forMainFrameOnly: true)
        configuration.userContentController.addUserScript(hideForwardingScript)
        webView = WKWebView(frame: CGRect.zero, configuration: configuration)
        
        super.init(coder: aDecoder)
        webView.navigationDelegate = self
    }
    
    deinit {
        webView.removeObserver(self, forKeyPath: "loading")
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
        webView.removeObserver(self, forKeyPath: "title")
        webView.stopLoading()
        
        print("Deallocating WebViewController!")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        backButton.enabled = false
        forwardButton.enabled = false
        
        window.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        
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
        
//        webView.addConstraints([
//            NSLayoutConstraint(item: spinner, attribute: .CenterX, relatedBy: .Equal, toItem: webView, attribute: .CenterX, multiplier: 1, constant: 0),
//            NSLayoutConstraint(item: spinner, attribute: .CenterY, relatedBy: .Equal, toItem: webView, attribute: .CenterY, multiplier: 1, constant: 0)
//            ])
        
        webView.addObserver(self, forKeyPath: "loading", options: .New, context: nil)
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .New, context: nil)
        webView.addObserver(self, forKeyPath: "title", options: .New, context: nil)
        webView.loadRequest(NSURLRequest(URL: webpageURL))
        
        // Swipe gesture setup
        let swipeUpRecognizer = UISwipeGestureRecognizer(target: self, action: "swipedUp:")
        swipeUpRecognizer.delegate = self
        swipeUpRecognizer.direction = .Up
        
        let swipeDownRecognizer = UISwipeGestureRecognizer(target: self, action: "swipedDown:")
        swipeDownRecognizer.delegate = self
        swipeDownRecognizer.direction = .Down
        
        webView.addGestureRecognizer(swipeUpRecognizer)
        webView.addGestureRecognizer(swipeDownRecognizer)
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
    
    @IBAction func actionButtonPressed(sender: UIBarButtonItem) {
        let subjectActivityItem = SubjectActivityItem(subject: "Look at what I found on Vendee")
        let promoText = "Love this! What do you think? @vendeefashion"
        
        var items = [AnyObject]()
        items.append(subjectActivityItem)
        items.append(promoText)
        items.append(webpageURL)
        
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        presentViewController(activityVC, animated: true, completion: nil)
    }
    
    @IBAction func reloadButtonPressed(sender: UIBarButtonItem) {
        if webView.loading {
            webView.stopLoading()
            animateSpinner?(false)
        } else {
            webView.loadRequest(NSURLRequest(URL: webpageURL))
            animateSpinner?(true)
        }
    }
    
    // MARK: - Key Value Observer
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        if keyPath == "loading" {
            backButton.enabled = webView.canGoBack
            forwardButton.enabled = webView.canGoForward
            reloadButton.image = webView.loading ? UIImage(named: "bar_stop") : UIImage(named: "bar_reload")
            
//            guard let change = change else { return }
//            if let val = change[NSKeyValueChangeNewKey] as? Bool {
//                if val {  }
//            }
        } else if keyPath == "estimatedProgress" {
            print("Estimated Progress: \(webView.estimatedProgress)")
            if webView.estimatedProgress > 0.850 && webView.estimatedProgress < 0.899 {
                animateSpinner?(false)
                showPopup?()
            }
        } else if keyPath == "title" {
            print("Webpage Title: \(webView.title)")
        }
    }
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        animateSpinner?(false)
    }
    
    func webView(webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: NSError) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
        
        animateSpinner?(false)
    }
    
    // MARK: - Helper methods
    
    private func setToolBarVisible(visible: Bool, animated: Bool) {
        if isToolBarVisible() == visible { return }
        
        let frame = toolBar.frame
        let height = frame.size.height
        let offsetY = visible ? -height : height
        
        UIView.animateWithDuration(animated ? 0.3 : 0.0) {
            self.toolBar.frame = CGRectOffset(frame, 0, offsetY)
        }
    }
    
    private func isToolBarVisible() -> Bool {
        return toolBar.frame.origin.y < CGRectGetMaxY(view.frame)
    }
}

extension WebViewController: UIGestureRecognizerDelegate {
    
    func swipedUp(recognizer: UISwipeGestureRecognizer) {
        print("swipedUp")
        delegate?.swipedUp()
        setToolBarVisible(false, animated: true)
    }
    
    func swipedDown(recognizer: UISwipeGestureRecognizer) {
        print("swipedDown")
        delegate?.swipedDown()
        setToolBarVisible(true, animated: true)
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}