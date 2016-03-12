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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
