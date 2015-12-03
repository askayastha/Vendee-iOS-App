//
//  CustomSFSafariViewController.swift
//  FlickShop
//
//  Created by Ashish Kayastha on 12/4/15.
//  Copyright © 2015 Ashish Kayastha. All rights reserved.
//

import UIKit
import SafariServices

class CustomSFSafariViewController: SFSafariViewController {
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

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
