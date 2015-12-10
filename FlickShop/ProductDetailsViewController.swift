//
//  ProductDetailsViewController.swift
//  FlickShop
//
//  Created by Ashish Kayastha on 10/9/15.
//  Copyright © 2015 Ashish Kayastha. All rights reserved.
//

import UIKit
import Alamofire
import AVFoundation

class ProductDetailsViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    private let reuseIdentifier = "CustomPhotoCell"
    private let footerViewIdentifier = "FooterView"
    private let headerViewIdentifier = "HeaderView"
    
    let search = Search()
//    let imageCache = NSCache()
//    let brandImageCache = NSCache()
    let scout = ImageScout()
    
    var requestingData = false
    var productCount = 0
    var productCategory: String!
    var product: Product!
    var brands: [Brand]!
    var headerViewHeight: CGFloat = 0
    var htmlDescription = NSAttributedString(string: "", attributes: nil)

//    override func preferredStatusBarStyle() -> UIStatusBarStyle {
//        return .LightContent
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
//        productCategory = product.categories?[0]
        
//        navigationItem.title = product.name
        navigationController?.navigationBar.translucent = false
//        navigationController?.setNavigationBarHidden(false, animated: false)
//        navigationController?.navigationBar.barStyle = UIBarStyle.Default
        navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        
        setupView()
        calculateHeaderHeight()
        print("MORE REQUESTS")
        requestDataFromShopStyleForCategory(productCategory)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func calculateHeaderHeight() {
        
        if let description = product.productDescription {
            print(description)
            let htmlData = description.dataUsingEncoding(NSUnicodeStringEncoding)!
            let font = UIFont(name: "ProximaNova-Regular", size: 14.0)!
            let horizontalPadding = CGFloat(15)
            let verticalPadding = CGFloat(15)
            let titleHeight = CGFloat(20)
            let nextSectionHeight = CGFloat(21)
            let nextLinePaddingHeight = CGFloat(5)
            let nextSectionPaddingHeight = CGFloat(10)
            
            do {
                let attribString = try NSMutableAttributedString(
                    data: htmlData,
                    options: [ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType ],
                    documentAttributes: nil)
                
                attribString.addAttribute(NSFontAttributeName, value: font, range: NSMakeRange(0, attribString.length))
                
                htmlDescription = attribString
                
                let rect = attribString.boundingRectWithSize(CGSizeMake(CGRectGetWidth(collectionView!.bounds) - horizontalPadding * 2, CGFloat(MAXFLOAT)
                    ), options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
                
                headerViewHeight = verticalPadding + titleHeight + nextLinePaddingHeight + ceil(rect.height) + nextSectionPaddingHeight + nextSectionHeight + verticalPadding
                print(headerViewHeight)
                
            } catch {
                print(error)
            }
        }
    }
    
    private func setupView() {
        collectionView!.contentInset = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
//        collectionView!.contentInset = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        var numberOfColumns = 2
        
        var contentWidth: CGFloat {
            let insets = collectionView!.contentInset
            
//            return CGRectGetWidth(collectionView!.bounds) - 12.0
            return CGRectGetWidth(collectionView!.bounds) - (insets.left + insets.right) - 4.0
        }
        
        let columnWidth = contentWidth / CGFloat(numberOfColumns)
        print("COLUMN WIDTH: \(columnWidth)")
        
//        let layout = UICollectionViewFlowLayout()
//        layout.itemSize = CGSize(width: columnWidth, height: 300)
//        layout.minimumInteritemSpacing = 4.0
//        layout.minimumLineSpacing = 4.0
        
//        layout.headerReferenceSize = CGSize(width: collectionView!.bounds.size.width, height: 300.0)
//        layout.footerReferenceSize = CGSize(width: collectionView!.bounds.size.width, height: 100.0)
        
//        collectionView!.collectionViewLayout = layout
        // Register cell classes
//        self.collectionView!.registerClass(CustomPhotoCell.self, forCellWithReuseIdentifier: reuseIdentifier)
//        collectionView!.registerClass(CustomPhotoLoadingCell.classForCoder(), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: footerViewIdentifier)
//        collectionView!.registerClass(ProductDetailsHeaderView.classForCoder(), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerViewIdentifier)
        
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
            search.parseShopStyleForItemOffset(search.lastItem, withLimit: limit, forCategory: category) { [weak self] success, lastItem in
                
                if let strongSelf = self {
                    if !success {
                        print("Products Count: \(lastItem)")
                        
                        print("Request Failed. Trying again...")
                        strongSelf.requestingData = false
                        strongSelf.requestDataFromShopStyleForCategory(category)
                        // self.showError()
                    } else {
                        strongSelf.requestingData = false
                        print("Product count: \(lastItem)")
                        
                        strongSelf.search.populatePhotoSizesForLimit(limit) { success, lastIndex in
                            let fromIndex = lastIndex - limit
                            let indexPaths = (fromIndex..<lastIndex).map { NSIndexPath(forItem: $0, inSection: 0) }
                            
                            strongSelf.collectionView!.performBatchUpdates({
                                strongSelf.collectionView!.insertItemsAtIndexPaths(indexPaths)
                                }, completion: { success in
                                    print("INSERTS SUCCESSFUL")
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

class CustomPhotoLoadingCell: UICollectionReusableView {
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        spinner.startAnimating()
        spinner.center = self.center
        addSubview(spinner)
    }
}

class ProductDetailsHeaderView: UICollectionReusableView {
//    @IBOutlet weak var sizesLabel: UILabel!
//    @IBOutlet weak var colorsLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        layer.cornerRadius = 5.0
        layer.masksToBounds = true
        
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
//        layer.cornerRadius = 5.0
//        layer.masksToBounds = true
    }
    
//    override func awakeFromNib() {
//        layer.cornerRadius = 5.0
//        layer.masksToBounds = true
//    }
}

extension ProductDetailsViewController {
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return search.lastItem
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! CustomPhotoCell
        
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
        
        if search.products.count - indexPath.item == 5 && search.products.count < 1000 {
            print("New request")
            requestDataFromShopStyleForCategory(productCategory)
        }
        print("Page \(indexPath.item)")
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        switch kind {
            case UICollectionElementKindSectionHeader:
                print("HEADER")
                let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: headerViewIdentifier, forIndexPath: indexPath) as! ProductDetailsHeaderView
                
                headerView.titleLabel.text = product.unbrandedName
                headerView.descriptionLabel.attributedText = htmlDescription
                
                return headerView
                
            case UICollectionElementKindSectionFooter:
                print("FOOTER")
                let footerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: footerViewIdentifier, forIndexPath: indexPath) as! CustomPhotoLoadingCell
                
                return footerView
                
            default:
                assert(false, "Unexpected element kind")
        }
    }
    
//    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
//        return CGSize(width: collectionView.frame.width, height: headerViewHeight)
//    }
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 4, left: 0, bottom: 0, right: 0)
    }
    
//    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
//        let feedVC = storyboard!.instantiateViewControllerWithIdentifier("FlickCollectionViewController") as? FlickCollectionViewController
//        
//        if let controller = feedVC {
//            controller.productCategory = productCategory
//            controller.indexPath  = indexPath
//            controller.search = search
//            navigationController?.pushViewController(controller, animated: true)
//        }
//    }
}

extension ProductDetailsViewController: TwoColumnLayoutDelegate {
    
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
