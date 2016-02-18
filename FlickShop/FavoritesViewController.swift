//
//  FavoritesViewController.swift
//  Vendee
//
//  Created by Ashish Kayastha on 2/11/16.
//  Copyright © 2016 Ashish Kayastha. All rights reserved.
//

import UIKit
import AVFoundation

class FavoritesViewController: UICollectionViewController {
    
    private(set) var productCount = 0
    private(set) var dataModelChanged: Bool = false
    
    var hideSpinner: (()->())?
    var brands = Brand.allBrands()
    var dataModel: DataModel!
    var search: Search!
    
    deinit {
        print("Deallocating FavoritesViewController !!!!!!!!!!!!!!!")
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: CustomNotifications.DataModelDidChangeNotification, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshDataModel", name: CustomNotifications.DataModelDidChangeNotification, object: nil)
        setupView()
        
        if dataModel.favoriteProducts.count > 0 {
            print("Initial favorites data request.")
            populatePhotosFromIndex(productCount)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print("FavoritesViewControllerWillAppear")
        
        if dataModelChanged {
            dataModelChanged = false
            productCount = 0
            search = Search(products: dataModel.favoriteProducts)
            
            // Reset content size of the collection view
            if let layout = collectionView!.collectionViewLayout as? TwoColumnLayout {
                layout.reset()
            }
            collectionView!.reloadData()
            
            if dataModel.favoriteProducts.count > 0 {
                populatePhotosFromIndex(productCount)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refreshDataModel() {
        print("Favorite Products: \(dataModel.favoriteProducts)")
        
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
        let populateLimit = 1
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        search.populatePhotoSizesFromIndex(index, withLimit: populateLimit) { [weak self] success, lastIndex in
            guard let strongSelf = self else { return }
            strongSelf.productCount += populateLimit
            let fromIndex = lastIndex - populateLimit
            let indexPaths = (fromIndex..<lastIndex).map { NSIndexPath(forItem: $0, inSection: 0) }
            
            strongSelf.collectionView!.performBatchUpdates({
                print("READY FOR INSERTS: \(lastIndex)")
                strongSelf.collectionView!.insertItemsAtIndexPaths(indexPaths)
                }, completion: { success in
                    print("INSERTS SUCCESSFUL")
                    if success && lastIndex != strongSelf.search.lastItem {
                        strongSelf.populatePhotosFromIndex(lastIndex)
                    } else {
                        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    }
                    strongSelf.hideSpinner?()
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
        
        cell.brandImageView.layer.borderColor = UIColor(red: 223/255, green: 223/255, blue: 223/255, alpha: 1.0).CGColor
        cell.brandImageView.layer.borderWidth = 0.5
        cell.brandImageView.layer.cornerRadius = 5.0
        cell.brandImageView.layer.masksToBounds = true
        cell.topImageViewLineSeparatorHeightConstraint.constant = 0.5
        cell.product = product
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
            if let brandName = product.brandName {
                let brandImageURL = self.brands.filter {$0.nickname == brandName}.first?.picURL
                
                dispatch_async(dispatch_get_main_queue()) {
                    if let imageURL = brandImageURL {
                        cell.brandImageView.pin_setImageFromURL(NSURL(string: imageURL)!)
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
            controller.brands = brands
            controller.dataModel = dataModel
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
