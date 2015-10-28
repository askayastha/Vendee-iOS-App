//
//  Category.swift
//  FlickShop
//
//  Created by Ashish Kayastha on 10/23/15.
//  Copyright © 2015 Ashish Kayastha. All rights reserved.
//

import Foundation
import UIKit

class Category {
    
    class func allCategories() -> [Category] {
        var categories = [Category]()
        if let URL = NSBundle.mainBundle().URLForResource("Categories", withExtension: "plist") {
            if let categoriesFromPlist = NSArray(contentsOfURL: URL) {
                for dictionary in categoriesFromPlist {
                    let category = Category(dictionary: dictionary as! NSDictionary)
                    categories.append(category)
                }
            }
        }
        return categories
    }
    
    var picture: UIImage
    var name: String
    var keyword: String
    
    init(picture: UIImage, name: String, keyword: String) {
        self.picture = picture
        self.name = name
        self.keyword = keyword
    }
    
    convenience init(dictionary: NSDictionary) {
        let image = dictionary["picture"] as? String
        let name = dictionary["name"] as? String
        let keyword = dictionary["keyword"] as? String
        let picture = UIImage(named: image!)
        self.init(picture: picture!, name: name!, keyword: keyword!)
    }
    
}
