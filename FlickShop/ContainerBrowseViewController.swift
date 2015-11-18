//
//  ContainerBrowseViewController.swift
//  FlickShop
//
//  Created by Ashish Kayastha on 11/8/15.
//  Copyright © 2015 Ashish Kayastha. All rights reserved.
//

import UIKit

class ContainerBrowseViewController: UIViewController {
    
    var productCategory: String!
    var brands: [Brand]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowBrowseCategory" {
            let controller = segue.destinationViewController as! BrowseCollectionViewController
            
            controller.productCategory = productCategory
            controller.brands = brands
        }
    }

}
