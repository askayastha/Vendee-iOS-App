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
import Crashlytics
import FirebaseAnalytics
import NVActivityIndicatorView

class FavoritesViewController: UICollectionViewController {
    
    struct FavoritesViewCellIdentifiers {
        static let customProductCell = "CustomPhotoCell"
        static let headerCell = "HeaderCell"
        static let footerCell = "FooterCell"
    }
    
    private(set) var productCount = 0
    private(set) var dataModelChanged = false
    private(set) var populatingData = false
    
    var animateSpinner: ((Bool)->())?
    var search: Search!
    var scout: PhotoScout!
    var loadMoreIndicator: NVActivityIndicatorView!
    
    let brandsModel = BrandsModel.sharedInstance()
    
    deinit {
        print("Deallocating FavoritesViewController!")
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: CustomNotifications.FavoritesModelDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: CustomNotifications.NetworkDidChangeToReachableNotification, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(refreshFavoritesModel), name: CustomNotifications.FavoritesModelDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(refreshFavoritesModel), name: CustomNotifications.NetworkDidChangeToReachableNotification, object: nil)
        
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
            scout = PhotoScout(products: favoriteProductsCopy, totalItems: favoriteProductsCopy.count)
            
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
        if search.lastItem - productCount > 0 && appDelegate.networkManager!.isReachable {
            populatePhotosFromIndex(productCount)
            
        } else if !appDelegate.networkManager!.isReachable {
            animateSpinner?(false)
            TSMessage.addCustomDesignFromFileWithName(Files.TSDesignFileName)
            TSMessage.showNotificationWithTitle("Network Error", subtitle: "Check your internet connection and try again later.", type: .Error)
            
        } else {
            animateSpinner?(false)
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
        
        collectionView!.registerClass(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: FavoritesViewCellIdentifiers.headerCell)
        collectionView!.registerClass(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: FavoritesViewCellIdentifiers.footerCell)
        collectionView!.contentInset = UIEdgeInsets(top: 0, left: 4, bottom: 64, right: 4)
        
        if let layout = collectionView!.collectionViewLayout as? TwoColumnLayout {
            layout.delegate = self
            layout.headerReferenceSize = CGSize(width: collectionView!.bounds.size.width, height: 50)
            layout.footerReferenceSize = CGSize(width: collectionView!.bounds.size.width, height: 50)
        }
    }
    
    private func populatePhotosFromIndex(index: Int) {
        if populatingData { return }
        
        print("populatePhotosFromIndex")
        populatingData = true
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        scout.populatePhotoSizesFromIndex(index, withLimit: NumericConstants.populateLimit) { [weak self] success, fromIndex, lastIndex in
            guard let strongSelf = self else { return }
            guard success else {
                print("GUARDING SUCCESS")
                strongSelf.animateSpinner?(false)
                strongSelf.populatingData = false
                strongSelf.populatePhotosFromIndex(fromIndex)
                return
            }
            strongSelf.productCount += lastIndex - fromIndex
            let indexPaths = (fromIndex..<lastIndex).map { NSIndexPath(forItem: $0, inSection: 0) }
            strongSelf.loadMoreIndicator.stopAnimation()
            
            strongSelf.collectionView!.performBatchUpdates({
                print("READY FOR INSERTS: \(lastIndex)")
                strongSelf.collectionView!.insertItemsAtIndexPaths(indexPaths)
                }, completion: { success in
                    strongSelf.populatingData = false
                    strongSelf.animateSpinner?(false)
                    
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
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(FavoritesViewCellIdentifiers.customProductCell, forIndexPath: indexPath) as! CustomPhotoCell
        
        // Configure the cell
        let product = search.products.objectAtIndex(indexPath.item) as! Product
        cell.product = product
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            if let brand = product.brand {
                let brandName = JSON(brand)["name"].string
                let brandImageURL = self.brandsModel.brands.filter { $0.nickname == brandName }.first?.picURL
                
                dispatch_async(dispatch_get_main_queue()) {
                    if let imageURL = brandImageURL {
                        cell.headerImageView.pin_setImageFromURL(NSURL(string: imageURL)!)
                    }
                }
            } else if let retailer = product.retailer {
                let retailerName = JSON(retailer)["name"].string
                let retailerImageURL = self.brandsModel.brands.filter { $0.nickname == retailerName }.first?.picURL
                
                dispatch_async(dispatch_get_main_queue()) {
                    if let imageURL = retailerImageURL {
                        cell.headerImageView.pin_setImageFromURL(NSURL(string: imageURL)!)
                    }
                }
            }
        }
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionElementKindSectionHeader {
            let cell = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: FavoritesViewCellIdentifiers.headerCell, forIndexPath: indexPath)
            
            // Reuse views
            if cell.subviews.count == 0 {
                let titleLabel = UILabel()
                titleLabel.font = UIFont(name: "CircularSPUI-Bold", size: 16.0)!
                titleLabel.textColor = UIColor(hexString: "#353535")
                titleLabel.text = "Favorites"
                titleLabel.textAlignment = .Center
                
                let itemsCountLabel = UILabel()
                itemsCountLabel.font = UIFont(name: "CircularSPUI-Book", size: 12.0)!
                itemsCountLabel.textColor = UIColor(hexString: "#353535")
                itemsCountLabel.textAlignment = .Center
                
                let headerView = UIStackView(arrangedSubviews: [titleLabel, itemsCountLabel])
                headerView.axis = .Vertical
                headerView.spacing = -2.0
                cell.addSubview(headerView)
                
                headerView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activateConstraints([
                    headerView.centerXAnchor.constraintEqualToAnchor(cell.centerXAnchor),
                    headerView.centerYAnchor.constraintEqualToAnchor(cell.centerYAnchor)
                    ])
            }
            
            let headerView = cell.subviews[0] as! UIStackView
            let itemsCountLabel = headerView.arrangedSubviews[1] as! UILabel
            itemsCountLabel.text = "\(search.lastItem) Items"
            
            return cell
            
        } else {
            let cell = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: FavoritesViewCellIdentifiers.footerCell, forIndexPath: indexPath)
            
            // Reuse views
            if cell.subviews.count == 0 {
                let spinnerSize = CGFloat(26)
                let frame = CGRect(x: (collectionView.bounds.size.width - spinnerSize) / 2, y: (50 - spinnerSize) / 2, width: spinnerSize, height: spinnerSize)
                loadMoreIndicator = NVActivityIndicatorView(frame: frame, type: .BallPulse, color: UIColor(white: 0.1, alpha: 0.5))
                loadMoreIndicator.hidesWhenStopped = true
                
                cell.addSubview(loadMoreIndicator)
                return cell
            }
            
            // Don't show load more indicator when all the items are loaded.
            if productCount == scout.totalItems {
                if let layout = collectionView.collectionViewLayout as? TwoColumnLayout {
                    layout.footerReferenceSize = CGSize(width: 0, height: 0)
                }
            } else {
                loadMoreIndicator.startAnimation()
            }
            
            return cell
        }
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let product = search.products.objectAtIndex(indexPath.item) as! Product
        
        // Log custom events
        FIRAnalytics.logEventWithName("Tapped_Favorite_Product", parameters: getAttributesForProduct(product) as? [String: NSObject])
        Answers.logCustomEventWithName("Tapped Favorite Product", customAttributes: getAttributesForProduct(product))
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let flickVC = mainStoryboard.instantiateViewControllerWithIdentifier("ContainerFlickViewController") as? ContainerFlickViewController
        
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
