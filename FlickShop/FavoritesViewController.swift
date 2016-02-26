//
//  FavoritesViewController.swift
//  Vendee
//
//  Created by Ashish Kayastha on 2/11/16.
//  Copyright © 2016 Ashish Kayastha. All rights reserved.
//

import UIKit
import AVFoundation
import TSMessages
import SwiftyJSON

class FavoritesViewController: UICollectionViewController {
    
    private(set) var productCount = 0
    private(set) var dataModelChanged = false
    private(set) var populatingData = false
    
    var hideSpinner: (()->())?
    var search: Search!
    let brands = BrandsModel.sharedInstance().brands
    var scout: PhotoScout!
    
    deinit {
        print("Deallocating FavoritesViewController !!!!!!!!!!!!!!!")
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: CustomNotifications.FavoritesModelDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: CustomNotifications.NetworkDidChangeToReachableNotification, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshFavoritesModel", name: CustomNotifications.FavoritesModelDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshFavoritesModel", name: CustomNotifications.NetworkDidChangeToReachableNotification, object: nil)
        
        setupView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print("FavoritesViewControllerWillAppear")
        
        if dataModelChanged {
            print("DATA MODEL CHANGED")
            dataModelChanged = false
            populatingData = false
            productCount = 0
            
            let favoriteProductsCopy = FavoritesModel.sharedInstance().favoriteProducts.mutableCopy() as! NSMutableOrderedSet
            search = Search(products: favoriteProductsCopy)
            scout = PhotoScout(products: favoriteProductsCopy)
            
            // Reset content size of the collection view
            if let layout = collectionView!.collectionViewLayout as? TwoColumnLayout {
                layout.reset()
            }
            collectionView!.reloadData()
        }
        populateData()
    }
    
    func populateData() {
        print("PopulateData Count: \(search.products.count)")
        if search.products.count > 0 && appDelegate.networkManager!.isReachable {
            populatePhotosFromIndex(productCount)
            
        } else if !appDelegate.networkManager!.isReachable {
            hideSpinner?()
            TSMessage.addCustomDesignFromFileWithName(Files.TSDesignFileName)
            TSMessage.showNotificationWithTitle("Network Error", subtitle: "Check your internet connection and try again later.", type: .Error)
            
        } else {
            hideSpinner?()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refreshFavoritesModel() {
        print("Favorite Products: \(FavoritesModel.sharedInstance().favoriteProducts)")
        
        // Mark data model as dirty
        dataModelChanged = true
    }
    
    private func setupView() {
        
        collectionView!.contentInset = UIEdgeInsets(top: -16, left: 4, bottom: 4, right: 4)
        // collectionView!.contentInset = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        
        if let layout = collectionView!.collectionViewLayout as? TwoColumnLayout {
            layout.delegate = self
        }
    }
    
    private func populatePhotosFromIndex(index: Int) {
        if populatingData { return }
        
        print("populatePhotosFromIndex")
        populatingData = true
        let populateLimit = 1
        
        scout.populatePhotoSizesFromIndex(index, withLimit: populateLimit) { [weak self] success, lastIndex in
            guard let strongSelf = self else { return }
            guard success else {
                print("GUARDING SUCCESS")
                strongSelf.hideSpinner?()
                strongSelf.populatingData = false
                strongSelf.populatePhotosFromIndex(lastIndex)
                return
            }
            strongSelf.productCount += populateLimit
            let fromIndex = lastIndex - populateLimit
            let indexPaths = (fromIndex..<lastIndex).map { NSIndexPath(forItem: $0, inSection: 0) }
            
            strongSelf.collectionView!.performBatchUpdates({
                print("READY FOR INSERTS: \(lastIndex)")
                strongSelf.collectionView!.insertItemsAtIndexPaths(indexPaths)
                }, completion: { success in
                    strongSelf.populatingData = false
                    strongSelf.hideSpinner?()
                    
                    if success && lastIndex != strongSelf.search.lastItem {
                        strongSelf.populatePhotosFromIndex(lastIndex)
                    } else {
                        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    }
                    print("INSERTS SUCCESSFUL")
            })
        }
    }
}

extension FavoritesViewController {
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return productCount
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(BrowseViewCellIdentifiers.customProductCell, forIndexPath: indexPath) as! CustomPhotoCell
        
        // Configure the cell
        let product = search.products.objectAtIndex(indexPath.item) as! Product
        
        cell.headerImageView.layer.borderColor = UIColor(red: 223/255, green: 223/255, blue: 223/255, alpha: 1.0).CGColor
        cell.headerImageView.layer.borderWidth = 0.5
        cell.headerImageView.layer.cornerRadius = 5.0
        cell.headerImageView.layer.masksToBounds = true
        cell.topImageViewLineSeparatorHeightConstraint.constant = 0.5
        cell.product = product
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            if let brand = product.brand {
                let brandName = JSON(brand)["name"].string
                let brandImageURL = self.brands.filter { $0.nickname == brandName }.first?.picURL
                
                dispatch_async(dispatch_get_main_queue()) {
                    if let imageURL = brandImageURL {
                        cell.headerImageView.pin_setImageFromURL(NSURL(string: imageURL)!)
                    }
                }
            } else if let retailer = product.retailer {
                let retailerName = JSON(retailer)["name"].string
                let retailerImageURL = self.brands.filter { $0.nickname == retailerName }.first?.picURL
                
                dispatch_async(dispatch_get_main_queue()) {
                    if let imageURL = retailerImageURL {
                        cell.headerImageView.pin_setImageFromURL(NSURL(string: imageURL)!)
                    }
                }
            }
        }
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let flickVC = storyboard!.instantiateViewControllerWithIdentifier("ContainerFlickViewController") as? ContainerFlickViewController
        
        if let controller = flickVC {
            controller.search = search
            controller.indexPath = indexPath
            controller.hidesBottomBarWhenPushed = true
            
            navigationController?.pushViewController(controller, animated: true)
        }
    }
}

extension FavoritesViewController: TwoColumnLayoutDelegate {
    
    func collectionView(collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: NSIndexPath, withWidth width: CGFloat) -> CGFloat {
        let product = search.products.objectAtIndex(indexPath.item) as! Product
        let boundingRect = CGRect(x: 0, y: 0, width: width, height: CGFloat(MAXFLOAT))
        var rect = CGRectZero
        
        if let imageSize = product.smallImageSize {
            rect = AVMakeRectWithAspectRatioInsideRect(imageSize, boundingRect)
        }
        
        return ceil(rect.size.height)
        // return rect.size.height
    }
}
