//
//  Functions.swift
//  AmazonProduct
//
//  Created by Ashish Kayastha on 9/1/15.
//  Copyright (c) 2015 Ashish Kayastha. All rights reserved.
//

import Foundation
import UIKit
import Dispatch

func afterDelay(seconds: Double, closure: () -> ()) {
    let when = dispatch_time(DISPATCH_TIME_NOW, Int64(seconds * Double(NSEC_PER_SEC)))
    dispatch_after(when, dispatch_get_main_queue(), closure)
}

func fixFrame(var frame: CGRect) -> CGRect {
    let headerView: CGFloat = 60.0
    let imageViewGap: CGFloat = 20.0
    let actionView: CGFloat = 52.2
    if frame.size.width > ScreenConstants.width {
        frame.size.width = ScreenConstants.width
        frame.size.height = ScreenConstants.height - headerView - imageViewGap - actionView
    }
    return frame
}

//    func showError() {
//        let alert = UIAlertController(title: "Whoops...", message: "There was an error. Please try again.", preferredStyle: .Alert)
//        let retryAction = UIAlertAction(title: "Retry", style: .Default, handler: { _ in
//            print("Failed Request. Trying again.")
//            self.requestData()
//        })
//
//        let OKAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
//
//        alert.addAction(retryAction)
//        alert.addAction(OKAction)
//
//        presentViewController(alert, animated: true, completion: nil)
//    }