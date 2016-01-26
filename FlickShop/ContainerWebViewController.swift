//
//  ContainerWebViewController.swift
//  FlickShop
//
//  Created by Ashish Kayastha on 1/21/16.
//  Copyright © 2016 Ashish Kayastha. All rights reserved.
//

import UIKit

class ContainerWebViewController: UIViewController {
    
    var url: NSURL!
    var webViewController: WebViewController?
    var backButtonHidden = false
    
    @IBOutlet weak var backButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButtonTapped(sender: UIButton) {
        navigationController?.popViewControllerAnimated(true)
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EmbedWebView" {
            webViewController = segue.destinationViewController as? WebViewController
            webViewController?.url = url
            webViewController?.delegate = self
        }
    }

}

extension ContainerWebViewController: SwipeDelegate {
    
    func swipedUp() {
        if backButtonHidden { return }
        
        // Hide button with animation
        UIView.animateWithDuration(0.3, animations: {
            self.backButton.transform = CGAffineTransformMakeScale(0.1, 0.1)
            self.backButton.alpha = 0.0
            }, completion: { _ in
                self.backButtonHidden = true
        })
    }
    
    func swipedDown() {
        if !backButtonHidden { return }
        
        // Show button with animation
        UIView.animateWithDuration(0.3, animations: {
            self.backButton.transform = CGAffineTransformIdentity
            self.backButton.alpha = 1.0
            }, completion: { _ in
                self.backButtonHidden = false
        })
    }
}
