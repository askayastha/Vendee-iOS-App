//
//  MoreViewController.swift
//  FlickShop
//
//  Created by Ashish Kayastha on 2/12/16.
//  Copyright © 2016 Ashish Kayastha. All rights reserved.
//

import UIKit
import MessageUI

class MoreViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        
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

        case (0, 0):    // FAQs
            break
        case (0, 1):    // Contact us
            sendSupportEmail()
        
        case (1, 0):    // Rate us
            break
        case (1, 1):    // Share the app
            shareTheApp()
        
        case (2, 0):    // About us
            break
        case (2, 1):    // Terms of service
            break
        case (2, 2):    // Version
            break
        default:
            break
        }
    }
    
    // MARK: Helper methods
    private func shareTheApp() {
        let url = "https://www.vendeeapp.com/"
        let subjectActivityItem = SubjectActivityItem(subject: "Look at what I found")
        let promoText = "Try the Vendee Fashion Discovery App!"
        
        var items = [AnyObject]()
        items.append(promoText)
        items.append(url)
        items.append(subjectActivityItem)
        
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        presentViewController(activityVC, animated: true, completion: nil)
    }
    
    private func sendSupportEmail() {
        if MFMailComposeViewController.canSendMail() {
            let controller = MFMailComposeViewController()
            controller.setSubject("Vendee Feedback")
            controller.setToRecipients(["vendeeapp.dev@gmail.com"])
            controller.setMessageBody("Hey. I wanted to give you some feedback on the Vendee App.", isHTML: false)
            controller.mailComposeDelegate = self
//            controller.modalPresentationStyle = .FormSheet
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }

}

extension MoreViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
