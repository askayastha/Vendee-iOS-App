//
//  MoreViewController.swift
//  Vendee
//
//  Created by Ashish Kayastha on 2/12/16.
//  Copyright © 2016 Ashish Kayastha. All rights reserved.
//

import UIKit
import MessageUI
import DeviceKit
import Crashlytics
import iRate

class MoreViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        setTabBarVisible(true, animated: true)
        
        GoogleAnalytics.trackScreenForName("More View")
        Answers.logCustomEventWithName("More View", customAttributes: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    // MARK: - Table view delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        switch (indexPath.section, indexPath.row) {

        // Send Feedback
        case (0, 0):
            // Log custom events
            GoogleAnalytics.trackEventWithCategory("UI Action", action: "Tapped 'Send Feedback'", label: nil, value: nil)
            Answers.logCustomEventWithName("Tapped 'Send Feedback'", customAttributes: nil)
            
            sendSupportEmailWithSubject("General Feedback")
            
        // Report a Problem
        case (0, 1):
            // Log custom events
            GoogleAnalytics.trackEventWithCategory("UI Action", action: "Tapped 'Report a Problem'", label: nil, value: nil)
            Answers.logCustomEventWithName("Tapped 'Report a Problem'", customAttributes: nil)
            
            sendSupportEmailWithSubject("Something Isn't Working")
        
        // Rate Vendee
        case (1, 0):
            // Log custom events
            GoogleAnalytics.trackEventWithCategory("UI Action", action: "Tapped 'Rate Vendee'", label: nil, value: nil)
            Answers.logCustomEventWithName("Tapped 'Rate Vendee'", customAttributes: nil)
            
            let appStoreURL = NSURL(string: App.storeURL)!
            UIApplication.sharedApplication().openURL(appStoreURL)
        
        // Tell a Friend
        case (1, 1):
            // Log custom events
            GoogleAnalytics.trackEventWithCategory("UI Action", action: "Tapped 'Tell a Friend'", label: nil, value: nil)
            Answers.logCustomEventWithName("Tapped 'Tell a Friend'", customAttributes: nil)
            
            shareTheApp()
            
        // About Vendee
        case (2, 0):
            // Log custom events
            GoogleAnalytics.trackEventWithCategory("UI Action", action: "Tapped 'About Vendee'", label: nil, value: nil)
            Answers.logCustomEventWithName("Tapped 'About Vendee'", customAttributes: nil)
            
        // Third Party Licenses
        case (2, 1):
            // Log custom events
            GoogleAnalytics.trackEventWithCategory("UI Action", action: "Tapped 'Third Party Licenses'", label: nil, value: nil)
            Answers.logCustomEventWithName("Tapped 'Third Party Licenses'", customAttributes: nil)
            
        // Privacy Policy
        case (2, 2):
            // Log custom events
            GoogleAnalytics.trackEventWithCategory("UI Action", action: "Tapped 'Privacy Policy'", label: nil, value: nil)
            Answers.logCustomEventWithName("Tapped 'Privacy Policy'", customAttributes: nil)
            
        default:
            break
        }
    }
    
    // MARK: Helper methods
    private func shareTheApp() {
        let url = "https://vendeeapp.com"
        let subjectActivityItem = SubjectActivityItem(subject: "Look at what I found")
        let promoText = "Find all that's new in Fashion with Vendee!"
        let secondaryPromoText = "Get the app for free in the App Store."
        
        var items = [AnyObject]()
        items.append(promoText)
        items.append(url)
        items.append(subjectActivityItem)
        items.append(secondaryPromoText)
        
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        presentViewController(activityVC, animated: true, completion: nil)
        activityVC.view.tintColor = UIColor.vendeeColor()
    }
    
    private func sendSupportEmailWithSubject(subject: String) {
        var messageBody: String {
            let device = Device()
            return "\n\n\nVersion: \(getAppVersionBuild())\niOS: \(device.systemVersion)\nModel: \(device)"
        }
        
        if MFMailComposeViewController.canSendMail() {
            let controller = MFMailComposeViewController()
            controller.setSubject(subject)
            controller.setMessageBody(messageBody, isHTML: false)
            controller.setToRecipients(["vendeefashion.ios@gmail.com"])
            controller.mailComposeDelegate = self
            self.presentViewController(controller, animated: true, completion: nil)
            controller.view.tintColor = UIColor.vendeeColor()
        }
    }
    
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

extension MoreViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
