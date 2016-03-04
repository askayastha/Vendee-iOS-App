//
//  AboutViewController.swift
//  Vendee
//
//  Created by Ashish Kayastha on 2/13/16.
//  Copyright © 2016 Ashish Kayastha. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {
    
    @IBOutlet weak var appVersionLabel: UILabel!
    @IBOutlet weak var copyrightLabel: UILabel!
    @IBOutlet weak var thirdPartyLibrariesLabel: UILabel!
    
    var thirdPartyLibraries = [
        "Alamofire by Alamofire Software Foundation",
        "ImageScout by Reda Lemeden",
        "MBProgressHUD by Matej Bukovinski",
        "SwiftyJSON by Ruoyu Fu",
        "PINRemoteImage by Pinterest, Inc.",
        "NMRangeSlider by Null Monkey Pty. Ltd.",
        "TSMessages by  Felix Krause",
        "DeviceKit by Dennis Weissmann"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "About Vendee"
        appVersionLabel.text = "Vendee 1.0"
        copyrightLabel.text = "© 2016 Ashish Kayastha"
        thirdPartyLibrariesLabel.text = thirdPartyLibraries.joinWithSeparator("\n")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        GoogleAnalytics.trackScreenForName("About View")
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
