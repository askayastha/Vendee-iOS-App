//
//  AboutViewController.swift
//  Vendee
//
//  Created by Ashish Kayastha on 2/13/16.
//  Copyright © 2016 Ashish Kayastha. All rights reserved.
//

import UIKit
import Crashlytics
import TTTAttributedLabel

class AboutViewController: UIViewController {
    
    @IBOutlet weak var creditsView: UIStackView!
    @IBOutlet weak var vendeeLogo: UIImageView!
    @IBOutlet weak var appVersionLabel: UILabel!
    @IBOutlet weak var copyrightLabel: UILabel!
    @IBOutlet weak var appLinkLabel: TTTAttributedLabel!
    @IBOutlet weak var supportLinkLabel: TTTAttributedLabel!
    
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
        
        // Need to change the UIStackView spacing for iPhone 4S and before due to limited screen height
        if ScreenConstants.height == 480 {
            creditsView.spacing = 10.0
        }
        
        vendeeLogo.layer.cornerRadius = 10.0
        vendeeLogo.layer.masksToBounds = true
        appVersionLabel.text = "Version \(getAppVersion())"
        copyrightLabel.text = "© 2016 Ashish Kayastha.\nAll rights reserved."
        
        appLinkLabel.linkAttributes = [
            kCTForegroundColorAttributeName: UIColor.vendeeColor(),
            NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue,
            NSUnderlineColorAttributeName: UIColor.vendeeColor()
        ]
        appLinkLabel.activeLinkAttributes = [
            NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleNone.rawValue
        ]
        appLinkLabel.addLinkToURL(NSURL(string: "http://vendeeapp.com/")!, withRange: NSMakeRange(0, appLinkLabel.text!.characters.count))
        appLinkLabel.delegate = self
        
        supportLinkLabel.linkAttributes = [
            kCTForegroundColorAttributeName: UIColor.vendeeColor(),
            NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue,
            NSUnderlineColorAttributeName: UIColor.vendeeColor()
        ]
        supportLinkLabel.activeLinkAttributes = [
            NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleNone.rawValue
        ]
        supportLinkLabel.addLinkToURL(NSURL(string: "http://thedesignmonk.com/")!, withRange: NSMakeRange(0, supportLinkLabel.text!.characters.count))
        supportLinkLabel.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        GoogleAnalytics.trackScreenForName("About View")
        Answers.logCustomEventWithName("About View", customAttributes: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension AboutViewController: TTTAttributedLabelDelegate {
    
    func attributedLabel(label: TTTAttributedLabel!, didSelectLinkWithURL url: NSURL!) {
        UIApplication.sharedApplication().openURL(url)
    }
}
