//
//  SimilarProductsCell.swift
//  FlickShop
//
//  Created by Ashish Kayastha on 1/16/16.
//  Copyright © 2016 Ashish Kayastha. All rights reserved.
//

import UIKit
import Alamofire
import PINRemoteImage

class SimilarProductCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageViewHeightLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var topImageViewLineSeparatorHeightConstraint: NSLayoutConstraint!
//    @IBOutlet weak var brandImageView: UIImageView!
    @IBOutlet weak var brandNameLabel: UILabel!
    @IBOutlet weak var discountLabel: UILabel!
    
    var spinner: UIActivityIndicatorView!
    
    var product: Product? {
        didSet {
            if let product = product {
                brandNameLabel.text = product.brandedName
                
                if let salePrice = product.salePrice {
                    let discount = (product.price! - salePrice) * 100 / product.price!
                    discountLabel.text = "\(Int(discount))% Off"
                } else {
                    discountLabel.text = "0% Off"
                }
                
                // imageView.pin_updateWithProgress = true
                imageView.pin_setImageFromURL(NSURL(string: product.smallImageURLs!.first!)!) { _ in
                    self.spinner.stopAnimating()
                }
                
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
//        layer.cornerRadius = 5.0
//        layer.masksToBounds = true
        
//        layer.borderColor = UIColor(red: 223/255, green: 223/255, blue: 223/255, alpha: 1.0).CGColor
//        // layer.borderColor = UIColor.lightGrayColor().CGColor
//        layer.borderWidth = 0.5
        
        spinner = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        spinner.hidesWhenStopped = true
        spinner.center = CGPoint(x: 130 / 2, y: 50 + (150/2))
        contentView.addSubview(spinner)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
//        brandImageView.image = nil
        spinner.startAnimating()
    }
    
    override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes) {
        super.applyLayoutAttributes(layoutAttributes)
        
        if let attributes = layoutAttributes as? TwoColumnLayoutAttributes {
            imageViewHeightLayoutConstraint.constant = attributes.photoHeight
        }
    }
    
}

