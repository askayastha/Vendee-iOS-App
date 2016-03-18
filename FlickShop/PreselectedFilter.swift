//
//  PreselectedFilter.swift
//  Vendee
//
//  Created by Ashish Kayastha on 2/26/16.
//  Copyright © 2016 Ashish Kayastha. All rights reserved.
//

import CloudKit

class PreselectedFilter: NSObject, NSCoding {
    
    var category: String!
    var filterParams: String!
    
    init(record : CKRecord) {
        self.category = record.objectForKey("Category") as? String
        self.filterParams = record.objectForKey("FilterParams") as? String
    }
    
    required init?(coder aDecoder: NSCoder) {
        category = aDecoder.decodeObjectForKey("Category") as? String
        filterParams = aDecoder.decodeObjectForKey("FilterParams") as? String
        
        super.init()
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(category, forKey: "Category")
        aCoder.encodeObject(filterParams, forKey: "FilterParams")
    }
}