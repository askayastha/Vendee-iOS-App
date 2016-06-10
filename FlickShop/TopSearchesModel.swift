//
//  TopSearchesModel.swift
//  Vendee
//
//  Created by Ashish Kayastha on 6/8/16.
//  Copyright © 2016 Ashish Kayastha. All rights reserved.
//

import Foundation
import CloudKit
import Crashlytics
import FirebaseAnalytics

private let TopSearchesModelSingleton = TopSearchesModel()

class TopSearchesModel {
    
    class func sharedInstance() -> TopSearchesModel {
        return TopSearchesModelSingleton
    }
    
    private(set) var topSearches: [TopSearch]
    private let container : CKContainer
    private let publicDB : CKDatabase
    
    // This prevents others from using the default initializer for this class.
    private init() {
        topSearches = [TopSearch]()
        container = CKContainer.defaultContainer()
        publicDB = container.publicCloudDatabase
    }
    
    func documentsDirectory() -> NSURL {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[0]
    }
    
    func dataFileURL() -> NSURL {
        return documentsDirectory().URLByAppendingPathComponent("TopSearches.plist")
    }
    
    func saveTopSearches() {
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWithMutableData: data)
        archiver.encodeObject(topSearches, forKey: "TopSearches")
        archiver.finishEncoding()
        data.writeToURL(dataFileURL(), atomically: true)
    }
    
    func loadTopSearches() {
        // Load top searches from the disk
        let fileURL = dataFileURL()
        if NSFileManager.defaultManager().fileExistsAtPath(fileURL.path!) {
            if let data = NSData(contentsOfURL: fileURL) {
                let unarchiver = NSKeyedUnarchiver(forReadingWithData: data)
                topSearches = unarchiver.decodeObjectForKey("TopSearches") as! [TopSearch]
                unarchiver.finishDecoding()
            }
        }
        
        // Get the recent top searches from the cloud
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: CKRecordTypes.TopSearch, predicate: predicate)
        
        print("Start getting the latest top searches")
        publicDB.performQuery(query, inZoneWithID: nil) { results, error in
            if let error = error {
                print("Error Loading: \(error)")
                
                // Log custom events
                GoogleAnalytics.trackEventWithCategory("Error", action: "CloudKit Error", label: error.localizedDescription, value: nil)
                FIRAnalytics.logEventWithName("CloudKit_Error", parameters: ["Description": error.localizedDescription])
                Answers.logCustomEventWithName("CloudKit Error", customAttributes: ["Description": error.localizedDescription])
                
            } else {
                guard let results = results else { return }
                self.topSearches.removeAll(keepCapacity: true)
                
                for record in results {
                    let topSearch = TopSearch(record: record)
                    self.topSearches.append(topSearch)
                }
                self.saveTopSearches()
            }
        }
    }
}

class TopSearch: NSObject, NSCoding {
    
    var keyword: String!
    
    init(record : CKRecord) {
        self.keyword = record.objectForKey("Keyword") as? String
    }
    
    required init?(coder aDecoder: NSCoder) {
        keyword = aDecoder.decodeObjectForKey("Keyword") as? String
        
        super.init()
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(keyword, forKey: "Keyword")
    }
}
