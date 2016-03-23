//
//  LicensesViewController.swift
//  FlickShop
//
//  Created by Ashish Kayastha on 3/12/16.
//  Copyright © 2016 Ashish Kayastha. All rights reserved.
//

import UIKit
import Crashlytics

class LicensesViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Third Party Licenses"
        automaticallyAdjustsScrollViewInsets = false
        
        let path = NSBundle.mainBundle().pathForResource("licenses", ofType: "txt")!
        let licensesText = try? String(contentsOfFile: path)
        textView.text = licensesText
        
        // Swipe gesture setup
        let swipeUpGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipedUp(_:)))
        swipeUpGesture.delegate = self
        swipeUpGesture.direction = .Up
        
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipedDown(_:)))
        swipeDownGesture.delegate = self
        swipeDownGesture.direction = .Down
        
        view.addGestureRecognizer(swipeUpGesture)
        view.addGestureRecognizer(swipeDownGesture)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        textView.scrollEnabled = false
        
        GoogleAnalytics.trackScreenForName("Licenses View")
        Answers.logCustomEventWithName("Licenses View", customAttributes: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        textView.scrollEnabled = true
    }
    
//    override func viewWillLayoutSubviews() {
//        super.viewWillLayoutSubviews()
//        
//        textView.scrollRangeToVisible(NSMakeRange(0, 0))
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

extension LicensesViewController: UIGestureRecognizerDelegate {
    
    func swipedUp(recognizer: UISwipeGestureRecognizer) {
        print("swipedUp")
        setTabBarVisible(false, animated: true)
    }
    
    func swipedDown(recognizer: UISwipeGestureRecognizer) {
        print("swipedDown")
        setTabBarVisible(true, animated: true)
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}