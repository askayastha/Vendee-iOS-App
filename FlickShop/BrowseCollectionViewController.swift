//
//  BrowseCollectionViewController.swift
//  FlickShop
//
//  Created by Ashish Kayastha on 10/23/15.
//  Copyright © 2015 Ashish Kayastha. All rights reserved.
//

import UIKit
import Alamofire
import AVFoundation

class BrowseCollectionViewController: UICollectionViewController {
    
    private let cellIdentifier = "CustomPhotoCell"
    private let footerViewIdentifier = "FooterView"
    private let headerViewIdentifier = "HeaderView"
    
    let search = Search()
    let imageCache = NSCache()
    let brandImageCache = NSCache()
    let scout = ImageScout()
    
    var requestingData = false
    var productCount = 0
    var productCategory: String!
//    var product: Product!
    var brands = Brand.allBrands()
    
    //    override func preferredStatusBarStyle() -> UIStatusBarStyle {
    //        return .LightContent
    //    }
    
    deinit {
        print("Deallocating BrowseCollectionViewController !!!!!!!!!!!!!!!")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
//        productCategory = product.categories?[0]
        
//        navigationItem.title = product.name
//        navigationController?.navigationBar.translucent = false
        navigationController?.setNavigationBarHidden(true, animated: false)
//        navigationController?.navigationBar.barStyle = UIBarStyle.Default
//        navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        
        setupView()
        print("MORE REQUESTS")
        requestDataFromShopStyleForCategory(productCategory)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "FlickCategory" {
            let controller = segue.destinationViewController as! FlickCollectionViewController
            let indexPath = sender as! NSIndexPath
            
            controller.indexPath = indexPath
            controller.search = search
        }
    }
    
    private func setupView() {
        collectionView!.contentInset = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        //        collectionView!.contentInset = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        
        if let layout = collectionView!.collectionViewLayout as? TwoColumnLayout {
            layout.delegate = self
        }
    }
    
    private func requestDataFromShopStyleForCategory(category: String!) {
        let limit = 5
        
        if requestingData {
            return
        }
        
        requestingData = true
        
        if let category = category {
            search.parseShopStyleForItemOffset(search.lastItem, withLimit: limit, forCategory: category) { success in
                if !success {
                    print("Products Count: \(self.search.products.count)")
                    
                    print("Request Failed. Trying again...")
                    self.requestingData = false
                    self.requestDataFromShopStyleForCategory(self.productCategory)
                    // self.showError()
                } else {
                    self.requestingData = false
                    print("Product count: \(self.search.products.count)")
                    //                    self.collectionView!.reloadData()
                    
                    self.populatePhotoSizes { success in
                        let fromIndex = self.search.lastItem - 5
                        let indexPaths = (fromIndex..<self.search.lastItem).map { NSIndexPath(forItem: $0, inSection: 0) }
                        self.collectionView!.performBatchUpdates({
                            self.collectionView!.insertItemsAtIndexPaths(indexPaths)
                            }, completion: { success in
                                print("INSERT SUCCESSFUL")
                        })
                    }
                    
                    ////                    var indexPaths = [NSIndexPath]()
                    //
                    //                    for var i = self.search.lastItem - 5; i < self.search.lastItem; i++ {
                    //                        let indexPath = NSIndexPath(forItem: i, inSection: 0)
                    //                        print("NSIndexPath ***: \(i)")
                    //
                    //                        self.populatePhotoSizeForIndexPath(indexPath) { success in
                    //                            if success {
                    //                                print("NSIndexPath: \(self.productCount)")
                    //                                let newIndexPath = NSIndexPath(forItem: self.productCount, inSection: 0)
                    ////                                indexPaths.append(newIndexPath)
                    //                                self.productCount++
                    //
                    //                                self.collectionView!.performBatchUpdates({
                    //                                    self.collectionView!.insertItemsAtIndexPaths([newIndexPath])
                    //                                    }, completion: { success in
                    //                                        print("INSERT SUCCESSFUL")
                    //                                })
                    //                            }
                    //                        }
                    //                    }
                }
            }
        }
    }
    
    private func populatePhotoSizes(completion: (Bool) -> ()) {
        
        var success = false
        var count = 0
        let fromIndex = self.search.lastItem - 5
        
        for var i = fromIndex; i < self.search.lastItem; i++ {
            let product = self.search.products.objectAtIndex(i) as! Product
            
            scout.scoutImageWithURI(product.smallImageURL!) { error, size, type in
                if let unwrappedError = error {
                    print(unwrappedError.code)
                    
                } else {
                    let imageSize = CGSize(width: size.width, height: size.height)
                    product.smallImageSize = imageSize
                    print("\(count)*****\(imageSize)")
                    count++
                    
                    success = true
                }
                
                if count == 5 {
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        completion(success)
                    }
                }
            }
        }
    }
    
    private func populatePhotoSizeForIndexPath(indexPath: NSIndexPath, completion: (Bool) -> ()) {
        
        var success = false
        
        let product = self.search.products.objectAtIndex(indexPath.item) as! Product
        
        scout.scoutImageWithURI(product.smallImageURL!) { error, size, type in
            if let unwrappedError = error {
                print(unwrappedError.code)
                
            } else {
                product.smallImageSize = CGSize(width: size.width, height: size.height)
                print("\(indexPath.item)*****\(CGSize(width: size.width, height: size.height))")
                
                success = true
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                completion(success)
            }
        }
    }
    
    //    override func scrollViewDidScroll(scrollView: UIScrollView) {
    //        // Populate more photos when the scrollbar indicator is at 80%
    //        if scrollView.contentOffset.y + view.frame.size.height > scrollView.contentSize.height * 0.8 {
    //            print("New request")
    //            requestDataFromShopStyleForCategory(productCategory)
    //            print("ScrollView ContentOffset: \(scrollView.contentOffset.y)")
    //            print("ScrollView View Height: \(view.frame.size.height)")
    //            print("ScrollView ContentSize: \(scrollView.contentSize.height)")
    //        }
    //    }
}

extension BrowseCollectionViewController {
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return search.lastItem
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath) as! CustomPhotoCell
//        cell.layer.shouldRasterize = true
//        cell.layer.rasterizationScale = UIScreen.mainScreen().scale
        
        let product = search.products.objectAtIndex(indexPath.item) as! Product
        
        cell.brandImageView.layer.borderColor = UIColor(red: 223/255, green: 223/255, blue: 223/255, alpha: 1.0).CGColor
        cell.brandImageView.layer.borderWidth = 0.5
        cell.brandImageView.layer.cornerRadius = 5.0
        cell.brandImageView.layer.masksToBounds = true
        
        cell.product = product
        
        // Set the brand image
        if let brandName = product.brandName {
            if let image = brandImageCache.objectForKey(brandName) as? UIImage {
                cell.brandImageView.image = image
            } else {
                let brandImageURL = brands.filter {$0.nickname == brandName}.first?.picURL
                print("BRAND IMAGE URL: \(brandImageURL)")
                
                if let imageURL = brandImageURL {
                    cell.brandImageRequest = Alamofire.request(.GET, imageURL).validate(contentType: ["image/*"]).responseImage() {
                        response in
                        
                        let image = response.result.value
                        
                        if response.result.isSuccess && image != nil {
                            self.brandImageCache.setObject(image!, forKey: brandName)
                            
                            cell.brandImageView.image = image
                        }
                    }
                }
            }
        }
        
        // Set the product image
        if let imageURL = product.smallImageURL {
            if let image = imageCache.objectForKey(imageURL) as? UIImage {
                cell.imageView.image = image
                
            } else {
                //                cell.spinner.startAnimating()
                
                // Download the image from the server, but this time validate the content-type of the returned response. If it's not an image, error will contain a value and therefore you won't do anything with the potentially invalid image response. The key here is that you store the Alamofire request object in the cell, for use when your asynchronous network call returns.
                cell.productImageRequest = Alamofire.request(.GET, imageURL).validate(contentType: ["image/*"]).responseImage() {
                    response in
                    
                    let image = response.result.value
                    
                    if response.result.isSuccess && image != nil {
                        // If you did not receive an error and you downloaded a proper photo, cache it for later.
                        self.imageCache.setObject(image!, forKey: imageURL)
                        
                        // Set the cell's image accordingly.
                        //                        cell.spinner.stopAnimating()
                        cell.imageView.image = image
                        
                    } else {
                        /* If the cell went off-screen before the image was downloaded, we cancel it and an NSURLErrorDomain (-999: cancelled) is returned. This is normal behavior. */
                    }
                }
            }
        }
        
        if search.products.count - (indexPath.item + 5) == 0 && search.products.count < 1000 {
            print("New request")
            requestDataFromShopStyleForCategory(productCategory)
        }
        print("Page \(indexPath.item)")
        print("ProductInfos count: \(search.products.count)")
        
        return cell
    }
    
    
//    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
//        return UIEdgeInsets(top: 4, left: 0, bottom: 0, right: 0)
//    }
    
//    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
//        //        performSegueWithIdentifier("FlickCollectionViewController", sender: indexPath)
//        let feedVC = storyboard!.instantiateViewControllerWithIdentifier("FlickCollectionViewController") as? FlickCollectionViewController
//        
//        if let controller = feedVC {
//            controller.productCategory = productCategory
//            controller.indexPath  = indexPath
//            controller.search = search
//            navigationController?.pushViewController(controller, animated: true)
//        }
//    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("FlickCategory", sender: indexPath)
    }
}

extension BrowseCollectionViewController: TwoColumnLayoutDelegate {
    
    func collectionView(collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: NSIndexPath, withWidth width: CGFloat) -> CGFloat {
        let product = search.products.objectAtIndex(indexPath.item) as! Product
        let boundingRect = CGRect(x: 0, y: 0, width: width, height: CGFloat(MAXFLOAT))
        var rect = CGRectZero
        
        if let imageSize = product.smallImageSize {
            rect = AVMakeRectWithAspectRatioInsideRect(imageSize, boundingRect)
        }
        
        return ceil(rect.size.height)
        //        return rect.size.height
    }
}