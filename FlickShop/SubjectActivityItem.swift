//
//  SubjectActivityItem.swift
//  FlickShop
//
//  Created by Ashish Kayastha on 1/25/16.
//  Copyright © 2016 Ashish Kayastha. All rights reserved.
//

import UIKit

class SubjectActivityItem: NSObject, UIActivityItemSource {
    
    var subject: String
    
    init(subject: String) {
        self.subject = subject
    }
    
    func activityViewControllerPlaceholderItem(activityViewController: UIActivityViewController) -> AnyObject {
        return ""
    }
    
    func activityViewController(activityViewController: UIActivityViewController, itemForActivityType activityType: String) -> AnyObject? {
        return ""
    }
    
    func activityViewController(activityViewController: UIActivityViewController, subjectForActivityType activityType: String?) -> String {
        return subject
    }
}
