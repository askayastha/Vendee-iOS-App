//
//  PreselectedFiltersModel.swift
//  Vendee
//
//  Created by Ashish Kayastha on 2/26/16.
//  Copyright © 2016 Ashish Kayastha. All rights reserved.
//

import Foundation
import CloudKit

private let preselectedFiltersModelSingleton = PreselectedFiltersModel()

class PreselectedFiltersModel {
    
    class func sharedInstance() -> PreselectedFiltersModel {
        return preselectedFiltersModelSingleton
    }
    
    var filters = [PreselectedFilter]()
    
    let container : CKContainer
    let publicDB : CKDatabase
    
    // This prevents others from using the default initializer for this class.
    private init() {
        container = CKContainer.defaultContainer()
        publicDB = container.publicCloudDatabase
    }
    
    func documentsDirectory() -> NSURL {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[0]
    }
    
    func dataFileURL() -> NSURL {
        return documentsDirectory().URLByAppendingPathComponent("PreselectedFilters.plist")
    }
    
    func savePreselectedFilters() {
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWithMutableData: data)
        archiver.encodeObject(filters, forKey: "PreselectedFilters")
        archiver.finishEncoding()
        data.writeToURL(dataFileURL(), atomically: true)
    }
    
    func loadPreselectedFilters() {
        // Load preselected filters from the disk
        let fileURL = dataFileURL()
        if NSFileManager.defaultManager().fileExistsAtPath(fileURL.path!) {
            if let data = NSData(contentsOfURL: fileURL) {
                let unarchiver = NSKeyedUnarchiver(forReadingWithData: data)
                filters = unarchiver.decodeObjectForKey("PreselectedFilters") as! [PreselectedFilter]
                unarchiver.finishDecoding()
            }
        }
        
        // Get the recent preselected filters from the cloud
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: CKRecordTypes.PreselectedFilter, predicate: predicate)
        
        print("Start getting the latest preselected filters")
        publicDB.performQuery(query, inZoneWithID: nil) { results, error in
            if let error = error {
                print("Error Loading: \(error)")
                
            } else {
                guard let results = results else { return }
                self.filters.removeAll(keepCapacity: true)
                
                for record in results {
                    let preselectedFilter = PreselectedFilter(record: record)
                    self.filters.append(preselectedFilter)
                }
                self.savePreselectedFilters()
            }
        }
    }
    
    func hasFilterParamsForCategory(category: String) -> Bool {
        let results = filters.filter { $0.category == category }
        let filterParams = results.first?.filterParams
        guard let params = filterParams else { return false }
        
        return results.count > 0 && !params.isEmpty
    }
    
    func getFilterParamsForCategory(category: String) -> String? {
        if hasFilterParamsForCategory(category) {
            return filters.filter { $0.category == category }.first?.filterParams
        }
        return nil
    }
}
