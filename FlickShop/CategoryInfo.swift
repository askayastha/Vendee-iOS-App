//
//  CategoryInfo.swift
//  FlickShop
//
//  Created by Ashish Kayastha on 2/25/16.
//  Copyright © 2016 Ashish Kayastha. All rights reserved.
//

import UIKit
import SwiftyJSON

class CategoryInfo: NSObject, NSCoding {
    
    var id: String!
    var name: String!
    var shortName: String!
    var fullName: String!
    var parentId: String!
    var hasSizeFilter: Bool!
    var hasColorFilter: Bool!
    
    init(data: JSON) {
        // ShopStyle Properties
        self.id = data["id"].string
        self.name = data["name"].string
        self.shortName = data["shortName"].string
        self.fullName = data["fullName"].string
        self.parentId = data["parentId"].string
        self.hasSizeFilter = data["HasSizeFilter"].bool
        self.hasColorFilter = data["HasColorFilter"].bool
    }
    
    required init?(coder aDecoder: NSCoder) {
        // ShopStyle Properties
        id = aDecoder.decodeObjectForKey("Id") as? String
        name = aDecoder.decodeObjectForKey("Name") as? String
        shortName = aDecoder.decodeObjectForKey("ShortName") as? String
        fullName = aDecoder.decodeObjectForKey("FullName") as? String
        parentId = aDecoder.decodeObjectForKey("ParentId") as? String
        hasSizeFilter = aDecoder.decodeBoolForKey("HasSizeFilter")
        hasColorFilter = aDecoder.decodeBoolForKey("HasColorFilter")
        
        super.init()
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        // ShopStyle Properties
        aCoder.encodeObject(id, forKey: "Id")
        aCoder.encodeObject(name, forKey: "Name")
        aCoder.encodeObject(shortName, forKey: "ShortName")
        aCoder.encodeObject(fullName, forKey: "FullName")
        aCoder.encodeObject(parentId, forKey: "ParentId")
        aCoder.encodeBool(hasSizeFilter, forKey: "HasSizeFilter")
        aCoder.encodeBool(hasColorFilter, forKey: "HasColorFilter")
    }
}
