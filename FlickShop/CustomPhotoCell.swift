//
//  CustomPhotoCell.swift
//  Vendee
//
//  Created by Ashish Kayastha on 10/9/15.
//  Copyright © 2015 Ashish Kayastha. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class CustomPhotoCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageViewHeightLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var topImageViewLineSeparatorHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var headerTitleLabel: UILabel!
    @IBOutlet weak var discountLabel: UILabel!
    
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
        
        var discountText = "0% Off"
        if let salePrice = product.salePrice {
            let discount = (product.price! - salePrice) * 100 / product.price!
            discountText = "\(Int(discount))% Off"
        }
        discountLabel.text = discountText
        imageView.pin_setImageFromURL(NSURL(string: product.smallImageURLs!.first!)!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        layer.borderColor = UIColor(hexString: "#DFDFDF")?.CGColor
        layer.borderWidth = 0.5
        layer.cornerRadius = 5.0
        layer.masksToBounds = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
        headerImageView.image = nil
        headerTitleLabel.text = nil
        discountLabel.text = nil
    }
    
    override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes) {
        super.applyLayoutAttributes(layoutAttributes)
        
        if let attributes = layoutAttributes as? TwoColumnLayoutAttributes {
            imageViewHeightLayoutConstraint.constant = attributes.photoHeight
        }
    }
    
}
