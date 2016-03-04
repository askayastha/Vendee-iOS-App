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

class MoreViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        Google.sendAnalyticsForScreenView("More View")
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
            sendSupportEmailWithSubject("General Feedback")
        
        // Report a Problem
        case (0, 1):
            sendSupportEmailWithSubject("Something Isn't Working")
        
        // Rate this app
        case (1, 0):
            break
        
        // Share this app
        case (1, 1):
            shareTheApp()
            
        default:
            break
        }
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        switch (indexPath.section, indexPath.row) {
        case (2, 1):
            return nil
            
        default:
            return indexPath
        }
    }
    
    // MARK: Helper methods
    private func shareTheApp() {
        let url = "https://vendeeapp.com/"
        let subjectActivityItem = SubjectActivityItem(subject: "Look at what I found")
        let promoText = "Try the Vendee Fashion Discovery App!"
        
        var items = [AnyObject]()
        items.append(promoText)
        items.append(url)
        items.append(subjectActivityItem)
        
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        presentViewController(activityVC, animated: true, completion: nil)
    }
    
    private func sendSupportEmailWithSubject(subject: String) {
        var messageBody: String {
            let dictionary = NSBundle.mainBundle().infoDictionary!
            let version = dictionary["CFBundleShortVersionString"] as! String
            let build = dictionary["CFBundleVersion"] as! String
            let device = Device()
            return "\n\n\nVersion: \(version) (\(build))\niOS: \(device.systemVersion)\nModel: \(device)"
        }
        
        if MFMailComposeViewController.canSendMail() {
            let controller = MFMailComposeViewController()
            controller.setSubject(subject)
            controller.setMessageBody(messageBody, isHTML: false)
            controller.setToRecipients(["vendeefashion.ios@gmail.com"])
            controller.mailComposeDelegate = self
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
}

extension MoreViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
