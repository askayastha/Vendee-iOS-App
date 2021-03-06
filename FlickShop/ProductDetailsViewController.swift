//
//  ProductDetailsViewController.swift
//  Vendee
//
//  Created by Ashish Kayastha on 10/9/15.
//  Copyright © 2015 Ashish Kayastha. All rights reserved.
//

import UIKit
import Alamofire
import AVFoundation
import TSMessages
import SwiftyJSON
import Crashlytics
import FirebaseAnalytics

class ProductDetailsViewController: UITableViewController {
    
    struct ProductDetailsViewCellIdentifiers {
        static let similarProductCell = "SimilarProductCell"
        static let headerCell = "HeaderCell"
    }
    
    private(set) var requestingData = false
    private(set) var productDetailsHeight: CGFloat = 0
    
    weak var delegate: ScrollEventsDelegate?
    var product: Product!
    var categoryIds: [String]!
    
    let search = Search()
    
    lazy private var spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        spinner.color = UIColor(white: 0.1, alpha: 0.5)
        spinner.startAnimating()
        
        return spinner
    }()
    
    enum DocumentType {
        case PlainText
        case HtmlText
    }
    
    @IBOutlet weak var productTitleLabel: UILabel!
    @IBOutlet weak var productDescLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var titleHeight: NSLayoutConstraint!
    
    deinit {
        print("Deallocating ProductDetailsViewController!")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
        // Spinner setup
        collectionView.addSubview(spinner)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activateConstraints([
            spinner.centerXAnchor.constraintEqualToAnchor(collectionView.centerXAnchor),
            spinner.centerYAnchor.constraintEqualToAnchor(collectionView.centerYAnchor)
            ])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Helper methods
    
    private func animateSpinner(animate: Bool) {
        if animate {
            self.spinner.startAnimating()
            UIView.animateWithDuration(0.3, animations: {
                self.spinner.transform = CGAffineTransformIdentity
                self.spinner.alpha = 1.0
                }, completion: nil)
            
        } else {
            UIView.animateWithDuration(0.3, animations: {
                self.spinner.transform = CGAffineTransformMakeScale(0.1, 0.1)
                self.spinner.alpha = 0.0
                }, completion: { _ in
                    self.spinner.stopAnimating()
            })
        }
    }
    
    private func convertText(text: String?, usingFont font: UIFont, forDocumentType docType: DocumentType) -> NSAttributedString? {
        guard let text = text else {
            return nil
        }
        
        print(text)
        let data = text.dataUsingEncoding(NSUnicodeStringEncoding)!
        var attribString: NSMutableAttributedString!
        
        do {
            switch docType {
            case .PlainText:
                attribString = try NSMutableAttributedString(
                    data: data,
                    options: [ NSDocumentTypeDocumentAttribute: NSPlainTextDocumentType ],
                    documentAttributes: nil)
                
            case .HtmlText:
                attribString = try NSMutableAttributedString(
                    data: data,
                    options: [ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType ],
                    documentAttributes: nil)
            }
            
            attribString.addAttribute(NSFontAttributeName, value: font, range: NSMakeRange(0, attribString.length))
            
            return attribString
            
        } catch {
            print(error)
            return nil
        }
    }
    
    private func heightForAttributedString(attribString: NSAttributedString?) -> CGFloat {
        guard let attribString = attribString else {
            return 0
        }
        
        let horizontalPadding = CGFloat(15)
        
        let rect = attribString.boundingRectWithSize(CGSizeMake(CGRectGetWidth(tableView.bounds) - horizontalPadding * 2, CGFloat(MAXFLOAT)
            ), options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
        
        return ceil(rect.height)
    }
    
    private func setupView() {
        // TableView stuff
        let verticalPadding = CGFloat(15)
        let labelPadding = CGFloat(5)
        let productDesc = convertText(product.productDescription, usingFont: UIFont(name: "Whitney-Book", size: 14.0)!, forDocumentType: .HtmlText)
        
        titleHeight.constant = heightForAttributedString(convertText(product.name, usingFont: UIFont(name: "Whitney-Semibold", size: 14.0)!, forDocumentType: .PlainText))
        print("Title Height: \(titleHeight.constant)")
        productDetailsHeight = verticalPadding + titleHeight.constant + labelPadding + heightForAttributedString(productDesc) + verticalPadding
        
        productTitleLabel.text = product.name
        productDescLabel.attributedText = productDesc
        
        tableView.registerClass(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: ProductDetailsViewCellIdentifiers.headerCell)
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        // CollectionView stuff
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 130, height: 200)
        layout.minimumInteritemSpacing = 4.0
        layout.scrollDirection = .Horizontal
        layout.minimumLineSpacing = 4.0
        
        collectionView!.collectionViewLayout = layout
        collectionView!.contentInset = UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 10)
    }
    
    private func requestDataFromShopStyleForCategory(category: String!) {        
        if requestingData { return }
        guard let category = category else { return }
        
        requestingData = true
        search.similarRequestShopStyleForItemOffset(search.lastItem, withLimit: 15, forCategory: category) { [weak self] success, description, lastItem in
            
            guard let strongSelf = self else { return }
            strongSelf.requestingData = false
            
            if !success {
                if strongSelf.search.retryCount < NumericConstants.retryLimit {
                    strongSelf.requestDataFromShopStyleForCategory(category)
                    strongSelf.search.incrementRetryCount()
                    print("Request Failed. Trying again...")
                    print("Request Count: \(strongSelf.search.retryCount)")
                } else {
                    strongSelf.search.resetRetryCount()
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    strongSelf.animateSpinner(false)
                    TSMessage.addCustomDesignFromFileWithName(Files.TSDesignFileName)
                    TSMessage.showNotificationWithTitle("Network Error", subtitle: description, type: .Error)
                }
                
            } else {
                strongSelf.animateSpinner(false)
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

extension ProductDetailsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return search.lastItem
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ProductDetailsViewCellIdentifiers.similarProductCell, forIndexPath: indexPath) as! SimilarProductCell
        
        cell.topImageViewLineSeparatorHeightConstraint.constant = 0
        cell.product = search.products.objectAtIndex(indexPath.item) as? Product
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let product = search.products.objectAtIndex(indexPath.item) as! Product
        
        // Log custom events
        FIRAnalytics.logEventWithName("Tapped_Similar_Product", parameters: getAttributesForProduct(product) as? [String: NSObject])
        Answers.logCustomEventWithName("Tapped Similar Product", customAttributes: getAttributesForProduct(product))
        
        print("CollectionViewDidSelectItemAtIndexPath")
        let flickVC = storyboard!.instantiateViewControllerWithIdentifier("ContainerFlickViewController") as? ContainerFlickViewController
        
        if let controller = flickVC {
            controller.productCategory = categoryIds?.first
            controller.indexPath  = indexPath
            controller.search = search
            navigationController?.pushViewController(controller, animated: true)
        }
    }
}

extension ProductDetailsViewController {
    
    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 0 {
            return productDetailsHeight
        } else if indexPath.section == 1 && indexPath.row == 0 {
            return 210.0
        }
        
        return 44.0
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 {
            print("SIMILAR REQUESTS")
            if let categories = product.categories {
                categoryIds = JSON(categories).arrayValue.map { $0["id"].stringValue }
                print("CATEGORIES: \(categoryIds)")
                requestDataFromShopStyleForCategory(categoryIds.first)
            }
        }
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableHeaderFooterViewWithIdentifier(ProductDetailsViewCellIdentifiers.headerCell)
        cell?.backgroundView = UIView()
        cell?.backgroundView?.backgroundColor = UIColor.whiteColor()
        
        // Reuse views
        if cell?.contentView.subviews.count == 0 {
            let sectionLabel = UILabel()
            sectionLabel.font = UIFont(name: "Whitney-Semibold", size: 16.0)!
            sectionLabel.textColor = UIColor(hexString: "#203143")
            cell?.contentView.addSubview(sectionLabel)
            
            sectionLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activateConstraints([
                NSLayoutConstraint.constraintsWithVisualFormat(
                    "H:|-15-[label]-15-|",
                    options: [],
                    metrics: nil,
                    views: ["label" : sectionLabel]),
                NSLayoutConstraint.constraintsWithVisualFormat(
                    "V:|[label]|",
                    options: [],
                    metrics: nil,
                    views: ["label": sectionLabel])
                ].flatten().map{$0})
            
            let separatorLine = UIView(frame: CGRect(x: 15, y: tableView.sectionHeaderHeight, width: view.frame.size.width - 15, height: 0.5))
//            separatorLine.backgroundColor = UIColor(red: 201/255, green: 198/255, blue: 204/255, alpha: 1.0)
            separatorLine.backgroundColor = tableView.separatorColor
            cell?.contentView.addSubview(separatorLine)
        }
        
        let sectionLabel = cell?.contentView.subviews[0] as! UILabel
        switch section {
        case 0:
            sectionLabel.text = "Product Description"
        case 1:
            sectionLabel.text = "Similar Products"
        default:
            sectionLabel.text = ""
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

extension ProductDetailsViewController: TSMessageViewProtocol {
    
    func customizeMessageView(messageView: TSMessageView!) {
        messageView.alpha = 0.8
    }
}
