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

class ProductDetailsViewController: UITableViewController {
    
    let search = Search()
    
    weak var delegate: ScrollEventsDelegate?
    var requestingData = false
    var product: Product!
    var brands: [Brand]!
    var headerViewHeight: CGFloat = 0
    var htmlDescription = NSAttributedString(string: "", attributes: nil)
    
    struct TableViewCellIdentifiers {
        static let similarProductCell = "SimilarProductCell"
        static let headerCell = "HeaderCell"
    }
    
    @IBOutlet weak var productTitleLabel: UILabel!
    @IBOutlet weak var productDescLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    deinit {
        print("Deallocating ProductDetailsViewController !!!!!!!!!!!!!!!")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        setupView()
        
        navigationController?.navigationBar.translucent = false
//        navigationController?.setNavigationBarHidden(false, animated: false)
//        navigationController?.navigationBar.barStyle = UIBarStyle.Default
        navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        
        print("SIMILAR REQUESTS")
        requestDataFromShopStyleForCategory(product.categories?.first)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func calculateHeaderHeight() {
        
        if let description = product.productDescription {
            print(description)
            let htmlData = description.dataUsingEncoding(NSUnicodeStringEncoding)!
            let font = UIFont(name: "Whitney-Book", size: 14.0)!
            let horizontalPadding = CGFloat(15)
            let verticalPadding = CGFloat(15)
            let labelPadding = CGFloat(5)
            let titleHeight = CGFloat(17)
            
            do {
                let attribString = try NSMutableAttributedString(
                    data: htmlData,
                    options: [ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType ],
                    documentAttributes: nil)
                
                attribString.addAttribute(NSFontAttributeName, value: font, range: NSMakeRange(0, attribString.length))
                
                htmlDescription = attribString
                
                let rect = attribString.boundingRectWithSize(CGSizeMake(CGRectGetWidth(collectionView!.bounds) - horizontalPadding * 2, CGFloat(MAXFLOAT)
                    ), options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
                
                headerViewHeight = verticalPadding + titleHeight + labelPadding + ceil(rect.height) + verticalPadding
                print(headerViewHeight)
                
            } catch {
                print(error)
            }
        }
    }
    
    private func setupView() {
        calculateHeaderHeight()
        productTitleLabel.text = product.name
        productDescLabel.attributedText = htmlDescription
        
        // TableView stuff
//        let headerNib = UINib(nibName: TableViewCellIdentifiers.headerCell, bundle: nil)
//        tableView.registerNib(headerNib, forHeaderFooterViewReuseIdentifier: TableViewCellIdentifiers.headerCell)
        tableView.registerClass(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: TableViewCellIdentifiers.headerCell)
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 130, height: 200)
        layout.minimumInteritemSpacing = 4.0
        layout.scrollDirection = .Horizontal
        layout.minimumLineSpacing = 4.0
        
        collectionView!.collectionViewLayout = layout
        collectionView!.contentInset = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
    }
    
    private func requestDataFromShopStyleForCategory(category: String!) {
        
        if requestingData {
            return
        }
        
        requestingData = true
        
        if let category = category {
            search.parseShopStyleForItemOffset(search.lastItem, withLimit: 15, forCategory: category) { [weak self] success, lastItem in
                
                if let strongSelf = self {
                    if strongSelf.search.retryCount < NumericConstants.retryLimit {
                        if !success {
                            strongSelf.requestingData = false
                            strongSelf.requestDataFromShopStyleForCategory(category)
                            strongSelf.search.incrementRetryCount()
                            print("Request Failed. Trying again...")
                            print("Request Count: \(strongSelf.search.retryCount)")
                            
                        } else {
                            strongSelf.requestingData = false
                            print("Product Count: \(lastItem)")
                            
                            let indexPaths = (0..<lastItem).map { NSIndexPath(forItem: $0, inSection: 0) }
                            
                            strongSelf.collectionView!.performBatchUpdates({
                                print("READY FOR INSERTS")
                                strongSelf.collectionView!.insertItemsAtIndexPaths(indexPaths)
                                }, completion: nil
                            )
                        }
                    }
                }
            }
        }
    }
}

extension ProductDetailsViewController: UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return search.lastItem
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(TableViewCellIdentifiers.similarProductCell, forIndexPath: indexPath) as! SimilarProductCell
        
        cell.topImageViewLineSeparatorHeightConstraint.constant = 0
        cell.product = search.products.objectAtIndex(indexPath.item) as? Product
        
        return cell
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

extension ProductDetailsViewController {
    
    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 0 {
            return headerViewHeight
        } else if indexPath.section == 1 && indexPath.row == 0 {
            return 210.0
        }
        
        return 44.0
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableHeaderFooterViewWithIdentifier(TableViewCellIdentifiers.headerCell)
//        let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.headerCell)
        
//        let headerLabel = cell?.viewWithTag(100) as! UILabel
        let headerLabel = (cell?.textLabel)!
        headerLabel.font = UIFont(name: "Whitney-Book", size: 12.0)!
        
        if section == 0 {
            headerLabel.text = "Details"
        } else if section == 1 {
            headerLabel.text = "Similar Products"
        } else {
            headerLabel.text = ""
        }
        
        return cell
    }
}

extension ProductDetailsViewController {
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        delegate?.didScroll()
    }
    
    override func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        delegate?.didEndDecelerating()
    }
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
