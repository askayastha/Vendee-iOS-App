//
//  SimilarProductsCell.swift
//  Vendee
//
//  Created by Ashish Kayastha on 1/16/16.
//  Copyright © 2016 Ashish Kayastha. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import PINRemoteImage

class SimilarProductCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageViewHeightLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var topImageViewLineSeparatorHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerTitleLabel: UILabel!
    @IBOutlet weak var discountLabel: UILabel!
    
    lazy private var spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        spinner.center = CGPoint(x: 130 / 2, y: 50 + (150/2))
        spinner.startAnimating()
        
        return spinner
    }()
    
    var product: Product! {
        didSet {
            updateUI()
        }
    }
    
    private func updateUI() {
        // Update header labels
        if let brand = product.brand {
            headerTitleLabel.text = JSON(brand)["name"].string
        } else if let retailer = product.retailer {
            headerTitleLabel.text = JSON(retailer)["name"].string
        }
        
        if let salePrice = product.salePrice {
            let discount = (product.price! - salePrice) * 100 / product.price!
            discountLabel.text = "\(Int(discount))% Off"
        } else {
            discountLabel.text = "0% Off"
        }        
        imageView.pin_setImageFromURL(NSURL(string: product.smallImageURLs!.first!)!) { _ in
            self.spinner.stopAnimating()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        print("CELL INITIALIZATION")
        
        contentView.addSubview(spinner)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
        spinner.startAnimating()
    }
    
    override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes) {
        super.applyLayoutAttributes(layoutAttributes)
        
        if let attributes = layoutAttributes as? TwoColumnLayoutAttributes {
            imageViewHeightLayoutConstraint.constant = attributes.photoHeight
        }
    }
    
}

