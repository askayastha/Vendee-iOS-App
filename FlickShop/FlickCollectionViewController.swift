//
//  FlickCollectionViewController.swift
//  FlickShop
//
//  Created by Ashish Kayastha on 9/12/15.
//  Copyright (c) 2015 Ashish Kayastha. All rights reserved.
//

import UIKit
import Alamofire
import MBProgressHUD
import SafariServices

struct FlickViewConstants {
    static var width = UIScreen.mainScreen().bounds.width
    static var height = UIScreen.mainScreen().bounds.height
}

class FlickCollectionViewController: UICollectionViewController {
    
    let cellIdentifier = "FlickPageCell"
    var productCategory = "women"
    
//    let imageCache = NSCache()
//    let brandImageCache = NSCache()
    var search = Search()
    
    var lastItem = 0
    var indexPath: NSIndexPath?
    var loadingHUDPresent = false
    var brands: [Brand]!
        
//    override func preferredStatusBarStyle() -> UIStatusBarStyle {
//        return .LightContent
//    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let indexPath = indexPath {
            collectionView!.scrollToItemAtIndexPath(indexPath, atScrollPosition: UICollectionViewScrollPosition.None, animated: false)
        }
    }
    
    deinit {
        print("Deallocating FlickCollectionViewController !!!!!!!!!!!!!!!")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        FlickViewConstants.width = collectionView!.bounds.width
        FlickViewConstants.height = collectionView!.bounds.height
        print("ViewDidLoad")
        
//        navigationController?.navigationBar.barStyle = UIBarStyle.Black
//        navigationController?.navigationBar.translucent = false
        navigationController?.setNavigationBarHidden(true, animated: false)
//        navigationController?.interactivePopGestureRecognizer?.delegate = self

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
//        self.collectionView!.registerClass(FlickPageCell.self, forCellWithReuseIdentifier: cellIdentifier)

        // Do any additional setup after loading the view.
        let nib = UINib(nibName: cellIdentifier, bundle: nil)
        collectionView!.registerNib(nib, forCellWithReuseIdentifier: cellIdentifier)
        
        collectionView!.backgroundColor = UIColor.lightGrayColor()
//        collectionView!.backgroundColor = UIColor.blackColor()
//        collectionView!.backgroundColor = UIColor(red: 96/255, green: 99/255, blue: 104/255, alpha: 1.0)
        collectionView!.decelerationRate = UIScrollViewDecelerationRateFast
        
        print("Initial Request")
//        requestData()
        
        if let indexPath = indexPath {
            print("INDEXPATH: \(indexPath.item)")
        } else {
            requestDataFromShopStyleForCategory(productCategory)
        }
        
//        requestDataFromShopStyleForCategory(productCategory)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return search.products.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if search.products.count - (indexPath.item + 1) == 0 && search.products.count < 1000 {
            print("New request")
            requestDataFromShopStyleForCategory(productCategory)
        }
        print("Page \(indexPath.item)")
        print("ProductInfos count: \(search.products.count)")
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath) as! FlickPageCell
        
//        cell.layer.shouldRasterize = true
//        cell.layer.rasterizationScale = UIScreen.mainScreen().scale
    
        let product = search.products.objectAtIndex(indexPath.item) as! Product
        
//        while product?.largeImageURL == nil {
//            search.products.removeObjectAtIndex(indexPath.item)
//
//            product = search.products.objectAtIndex(indexPath.item) as? Product
//        }
        
        // Configure the cell
        
        cell.imageViewHeightConstraint.constant = getImageViewHeight()
        cell.bottomImageViewLineSeparatorHeightConstraint.constant = 0.5
        cell.topImageViewLineSeparatorHeightConstraint.constant = 0.5
        cell.topLikesCommentsViewLineSeparatorHeightConstraint.constant = 0.5
        
        cell.brandImageView.layer.borderColor = UIColor(red: 223/255, green: 223/255, blue: 223/255, alpha: 1.0).CGColor
        cell.brandImageView.layer.borderWidth = 0.5
        cell.brandImageView.layer.cornerRadius = 5.0
        cell.brandImageView.layer.masksToBounds = true
                
        cell.product = product
        cell.delegate = self
        
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
        
        // Set the brand image
//        if let brandName = product.brandName {
//            if let image = brandImageCache.objectForKey(brandName) as? UIImage {
//                cell.brandImageView.image = image
//            } else {
//                let brandImageURL = brands.filter {$0.nickname == brandName}.first?.picURL
//                print("BRAND IMAGE URL: \(brandImageURL)")
//                
//                if let imageURL = brandImageURL {
//                    cell.brandImageRequest = Alamofire.request(.GET, imageURL).validate(contentType: ["image/*"]).responseImage() {
//                        response in
//                        
//                        let image = response.result.value
//                        
//                        if response.result.isSuccess && image != nil {
//                            self.brandImageCache.setObject(image!, forKey: brandName)
//                            
//                            cell.brandImageView.image = image
//                        }
//                    }
//                }
//            }
//        }
        
        // Set the product image
//        if let imageURL = product.largeImageURL {
//            if let image = imageCache.objectForKey(imageURL) as? UIImage {
//                cell.imageView.image = image
//                
//            } else {
//                cell.spinner.startAnimating()
//                
//                // Download the image from the server, but this time validate the content-type of the returned response. If it's not an image, error will contain a value and therefore you won't do anything with the potentially invalid image response. The key here is that you store the Alamofire request object in the cell, for use when your asynchronous network call returns.
//                cell.productImageRequest = Alamofire.request(.GET, imageURL).validate(contentType: ["image/*"]).responseImage() {
//                    response in
//                    
//                    let image = response.result.value
//                    
//                    if response.result.isSuccess && image != nil {
//                        // If you did not receive an error and you downloaded a proper photo, cache it for later.
//                        self.imageCache.setObject(image!, forKey: imageURL)
//                        
//                        // Set the cell's image accordingly.
//                        cell.spinner.stopAnimating()
//                        cell.imageView.image = image
//                        
//                    } else {
//                        /* If the cell went off-screen before the image was downloaded, we cancel it and an NSURLErrorDomain (-999: cancelled) is returned. This is normal behavior. */
//                    }
//                }
//            }
//        }
    
        return cell
    }
    
    
    // MARK: - Helper Methods
    
    func requestData() {
        if !loadingHUDPresent {
            let loadingHUD = MBProgressHUD.showHUDAddedTo(view, animated: true)
            loadingHUD.labelText = "Loading..."
            loadingHUD.userInteractionEnabled = false
        }
        
//        search.parseAmazonXMLForItemPage(search.lastItem/10 + 1) { success in
//            if !success {
//                print("Products Count: \(self.search.products.count)")
//                self.loadingHUDPresent = true
//                
//                print("Request Failed. Trying again...")
//                self.requestData()
////                self.showError()
//            } else {
//                
//                print("Product count: \(self.search.products.count)")
//                self.collectionView!.reloadData()
//                MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
//                self.loadingHUDPresent = false
//                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
//            }
//        }
    }
    
    private func requestDataFromShopStyleForCategory(category: String) {

        if !loadingHUDPresent {
            let loadingHUD = MBProgressHUD.showHUDAddedTo(view, animated: true)
            loadingHUD.labelText = "Loading..."
            loadingHUD.userInteractionEnabled = false
        }
        
        let limit = 10
        
        search.parseShopStyleForItemOffset(search.lastItem, withLimit: limit, forCategory: category) { success, lastItem
            in
            if !success {
                print("Products Count: \(lastItem)")
                self.loadingHUDPresent = true
                
                print("Request Failed. Trying again...")
                self.requestDataFromShopStyleForCategory(category)
                // self.showError()
            } else {
                
                print("Product count: \(lastItem)")
                self.collectionView!.reloadData()
                MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                self.loadingHUDPresent = false
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            }
        }
    }
    
//    func showError() {
//        let alert = UIAlertController(title: "Whoops...", message: "There was an error. Please try again.", preferredStyle: .Alert)
//        let retryAction = UIAlertAction(title: "Retry", style: .Default, handler: { _ in
//            print("Failed Request. Trying again.")
//            self.requestData()
//        })
//        
//        let OKAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
//        
//        alert.addAction(retryAction)
//        alert.addAction(OKAction)
//        
//        presentViewController(alert, animated: true, completion: nil)
//    }
    
    private func getImageViewHeight() -> CGFloat {
//        let collectionViewWidth = collectionView!.bounds.size.width
        let collectionViewHeight = collectionView!.bounds.size.height
        
        print("CollectionView Height: \(collectionViewHeight)")
        print("Screen Height: \(UIScreen.mainScreen().bounds.height)")
        
        return collectionViewHeight - (60 + 20 + 46 + 30)
    }
    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if segue.identifier == "MoreDetails" {
//            let controller = segue.destinationViewController as! ProductDetailsCollectionViewController
//            controller.product = sender as! Product
//        }
//    }
}

extension FlickCollectionViewController: SFSafariViewControllerDelegate {
    
    @available(iOS 9.0, *)
    func safariViewControllerDidFinish(controller: SFSafariViewController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension FlickCollectionViewController: FlickPageCellDelegate {
    
    func openItemInStoreWithURL(url: NSURL?) {
//        if #available(iOS 9.0, *) {
        if let url = url {
            let safariVC = SFSafariViewController(URL: url)
            safariVC.delegate = self
            presentViewController(safariVC, animated: true, completion: nil)
        }
    }
    
    func displayMoreDetailsForProduct(product: Product) {
        let detailsVC = storyboard!.instantiateViewControllerWithIdentifier("ProductDetailsViewController") as? ProductDetailsCollectionViewController
        
        if let controller = detailsVC {
            controller.product = product
            controller.productCategory = product.categories?[0]
            controller.brands = brands
            navigationController?.pushViewController(controller, animated: true)
        }
    }
}

//extension FlickCollectionViewController: UIGestureRecognizerDelegate {
//    
//    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
//        if navigationController?.viewControllers.count > 1 {
//            return true
//        }
//        
//        return false
//    }
//}
