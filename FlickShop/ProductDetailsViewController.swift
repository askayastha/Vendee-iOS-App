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

class ProductDetailsViewController: UITableViewController {
    
    private(set) var requestingData = false
    private(set) var productDetailsHeight: CGFloat = 0
    
    let search = Search()
    var brands = BrandsModel.sharedInstance().brands
    weak var delegate: ScrollEventsDelegate?
    var product: Product!
    
    var categoryIds: [String]!
    
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
    
    struct ProductDetailsViewCellIdentifiers {
        static let similarProductCell = "SimilarProductCell"
        static let headerCell = "HeaderCell"
    }
    
    @IBOutlet weak var productTitleLabel: UILabel!
    @IBOutlet weak var productDescLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var titleHeight: NSLayoutConstraint!
    
    deinit {
        print("Deallocating ProductDetailsViewController !!!!!!!!!!!!!!!")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        setupView()
        
        // Spinner setup
        collectionView.addSubview(spinner)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activateConstraints([
            spinner.centerXAnchor.constraintEqualToAnchor(collectionView.centerXAnchor),
            spinner.centerYAnchor.constraintEqualToAnchor(collectionView.centerYAnchor)
            ])
        
        print("SIMILAR REQUESTS")
        if let categories = product.categories {
            categoryIds = JSON(categories).arrayValue.map { $0["id"].stringValue }
            print("CATEGORIES: \(categoryIds)")
            requestDataFromShopStyleForCategory(categoryIds.first)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Helper methods
    
    private func hideSpinner() {
        if spinner.isAnimating() {
            spinner.stopAnimating()
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
        search.parseShopStyleForItemOffset(search.lastItem, withLimit: 15, forCategory: category) { [weak self] success, description, lastItem in
            
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
                    strongSelf.hideSpinner()
                    TSMessage.addCustomDesignFromFileWithName(Files.TSDesignFileName)
                    TSMessage.showNotificationWithTitle("Network Error", subtitle: description, type: .Error)
                }
                
            } else {
                strongSelf.hideSpinner()
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
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableHeaderFooterViewWithIdentifier(ProductDetailsViewCellIdentifiers.headerCell)
        
        cell?.backgroundView = UIView()
        cell?.backgroundView?.backgroundColor = UIColor.whiteColor()
        
        let label = UILabel()
        label.font = UIFont(name: "Whitney-Semibold", size: 16.0)!
        label.textColor = UIColor(red: 32/255, green: 49/255, blue: 67/255, alpha: 1.0)
        cell?.contentView.addSubview(label)
        
        switch section {
        case 0:
            label.text = "Product Description"
        case 1:
            label.text = "Similar Products"
        default:
            label.text = ""
        }
        
        label.translatesAutoresizingMaskIntoConstraints = false
//        cell?.contentView.addConstraints([
//            NSLayoutConstraint(item: label, attribute: .Leading, relatedBy: .Equal, toItem: cell?.contentView, attribute: .Leading, multiplier: 1, constant: 15),
//            NSLayoutConstraint(item: label, attribute: .Trailing, relatedBy: .Equal, toItem: cell?.contentView, attribute: .Trailing, multiplier: 1, constant: 15),
//            NSLayoutConstraint(item: label, attribute: .CenterY, relatedBy: .Equal, toItem: cell?.contentView, attribute: .CenterY, multiplier: 1, constant: 0)
//            ])
        NSLayoutConstraint.activateConstraints([
            NSLayoutConstraint.constraintsWithVisualFormat(
                "H:|-15-[label]-15-|",
                options: [],
                metrics: nil,
                views: ["label" : label]),
            NSLayoutConstraint.constraintsWithVisualFormat(
                "V:|[label]|",
                options: [],
                metrics: nil,
                views: ["label": label])
            ].flatten().map{$0})
        
        let separatorLine = UIView(frame: CGRect(x: 15, y: tableView.sectionHeaderHeight, width: view.frame.size.width - 15, height: 0.5))
        separatorLine.backgroundColor = UIColor(red: 201/255, green: 198/255, blue: 204/255, alpha: 1.0)
        cell?.contentView.addSubview(separatorLine)
        
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
