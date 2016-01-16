//
//  CustomPhotoCell.swift
//  FlickShop
//
//  Created by Ashish Kayastha on 10/9/15.
//  Copyright © 2015 Ashish Kayastha. All rights reserved.
//

import UIKit
import Alamofire
import PINRemoteImage

class CustomPhotoCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageViewHeightLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var topImageViewLineSeparatorHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var brandImageView: UIImageView!
    @IBOutlet weak var brandNameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var salePriceLabel: UILabel!
    
    var product: Product? {
        didSet {
            if let product = product {
                brandNameLabel.text = product.brandName ?? product.brandedName
                
                if let salePrice = product.formattedSalePrice {
                    priceLabel.attributedText = NSAttributedString(
                        string: product.formattedPrice ?? "",
                        attributes: [ NSStrikethroughStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue ]
                    )
                    
                    salePriceLabel.text = salePrice
                    
                } else {
                    priceLabel.text = ""
                    
                    salePriceLabel.text = product.formattedPrice ?? ""
                }
                
//                imageView.pin_updateWithProgress = true
                imageView.pin_setImageFromURL(NSURL(string: product.smallImageURLs!.first!)!)
                
            }
        }
    }
    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        
//        print("I AM HERE")
//    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        print("CELL INITIALIZATION")
        layer.cornerRadius = 5.0
        layer.masksToBounds = true
        
        layer.borderColor = UIColor(red: 223/255, green: 223/255, blue: 223/255, alpha: 1.0).CGColor
//        layer.borderColor = UIColor.lightGrayColor().CGColor
        layer.borderWidth = 0.5
    }
    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        
//        layer.cornerRadius = 5.0
//        layer.masksToBounds = true
//    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
        brandImageView.image = nil
    }
    
    override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes) {
        super.applyLayoutAttributes(layoutAttributes)
        
        if let attributes = layoutAttributes as? TwoColumnLayoutAttributes {
            imageViewHeightLayoutConstraint.constant = attributes.photoHeight
        }
    }
    
}
