//
//  PrivacyPolicyViewController.swift
//  Vendee
//
//  Created by Ashish Kayastha on 4/28/16.
//  Copyright © 2016 Ashish Kayastha. All rights reserved.
//

import UIKit
import Crashlytics
import FirebaseAnalytics

class PrivacyPolicyViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Privacy Policy"
        automaticallyAdjustsScrollViewInsets = false
        
        let path = NSBundle.mainBundle().pathForResource("privacy_policy", ofType: "txt")!
        let licensesText = try? String(contentsOfFile: path)
        textView.text = licensesText
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        textView.scrollEnabled = false
        textView.selectable = false
        textView.editable = false
        textView.textContainerInset = UIEdgeInsetsMake(15, 15, 15, 15)
        
        GoogleAnalytics.trackScreenForName("Privacy Policy View")
        FIRAnalytics.logEventWithName("Privacy_Policy_View", parameters: nil)
        Answers.logCustomEventWithName("Privacy Policy View", customAttributes: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        textView.scrollEnabled = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
