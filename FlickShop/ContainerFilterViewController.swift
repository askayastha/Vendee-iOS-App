//
//  ContainerFilterViewController.swift
//  Vendee
//
//  Created by Ashish Kayastha on 11/20/15.
//  Copyright © 2015 Ashish Kayastha. All rights reserved.
//

import UIKit

class ContainerFilterViewController: UIViewController, SideTabDelegate {
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    var containerVC: ContainerViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationBar.barTintColor = UIColor(red: 231/255, green: 231/255, blue: 231/255, alpha: 1.0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func done() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func reset() {
        appDelegate.filter.resetFilters()
        
        // Refresh side tab
        CustomNotifications.filterDidChangeNotification()
        
        // Refresh any visible filter view controllers
        CustomNotifications.filterDidClearNotification()
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EmbedContainer" {
            containerVC = segue.destinationViewController as? ContainerViewController
        } else if segue.identifier == "EmbedSideTab" {
            let controller = segue.destinationViewController as! SideTabViewController
            controller.delegate = self
        }
    }
    
    func showTab(identifier: String) {
        containerVC?.switchViewControllerForIdentifier(identifier)
    }

}
