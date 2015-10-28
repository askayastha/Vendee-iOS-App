//
//  Functions.swift
//  AmazonProduct
//
//  Created by Ashish Kayastha on 9/1/15.
//  Copyright (c) 2015 Ashish Kayastha. All rights reserved.
//

import Foundation
import Dispatch

func afterDelay(seconds: Double, closure: () -> ()) {
    let when = dispatch_time(DISPATCH_TIME_NOW, Int64(seconds * Double(NSEC_PER_SEC)))
    dispatch_after(when, dispatch_get_main_queue(), closure)
}