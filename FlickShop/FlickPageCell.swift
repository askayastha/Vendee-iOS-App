//
//  FlickPageCell.swift
//  Flip
//
//  Created by Ashish Kayastha on 9/12/15.
//  Copyright (c) 2015 Razeware LLC. All rights reserved.
//

import UIKit
import Alamofire

protocol FlickPageCellDelegate: class {
    func openItemInStoreWithURL(url: NSURL?)
    func displayMoreDetailsForProduct(product: Product)
}

class FlickPageCell: UICollectionViewCell {
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var brandNameLabel: UILabel!
    @IBOutlet weak var brandImageView: UIImageView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var salePriceLabel: UILabel!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomImageViewLineSeparatorHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var topImageViewLineSeparatorHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var topLikesCommentsViewLineSeparatorHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var buyButton: UIButton!
    
    weak var delegate: FlickPageCellDelegate?
    
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    
    var product: Product! {
        didSet {
            updateUI()
        }
    }
    
    var blurView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .Light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        
        return blurView
    }()
    
//    var productImageRequest: Alamofire.Request?
//    var brandImageRequest: Alamofire.Request?
    
    private func updateUI() {
        brandNameLabel.text = product.brandName ?? product!.brandedName
        
        if let salePrice = product.formattedSalePrice {
            priceLabel.attributedText = NSAttributedString(
                string: product.formattedPrice ?? "",
                attributes: [ NSStrikethroughStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue ]
            )
            
            salePriceLabel.text = salePrice
            
        } else {
            priceLabel.text = ""
            salePriceLabel.text = product!.formattedPrice ?? ""
        }
        
        imageView.pin_setImageFromURL(NSURL(string: product.largeImageURL!)!)
    }
    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        
//        print("I AM HERE")
//    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        print("$$$$$$$$$$ FlickCell initialization $$$$$$$$$$")

        layer.borderWidth = 0.5
        layer.borderColor = UIColor(red: 223/255, green: 223/255, blue: 223/255, alpha: 1.0).CGColor
        
        blurView.frame = bounds
        contentView.addSubview(blurView)
        
        spinner.center = CGPoint(
            x: FlickViewConstants.width / 2,
            y: FlickViewConstants.height / 2
        )
        
        spinner.hidesWhenStopped = true
        contentView.addSubview(spinner)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        buyButton.layer.cornerRadius = 5.0
        buyButton.layer.masksToBounds = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        print("Yay. I am getting reused.")
        
        imageView.image = nil
        brandImageView.image = nil
        priceLabel.text = nil
//        productImageRequest?.cancel()
//        brandImageRequest?.cancel()
//        productImageRequest = nil
//        brandImageRequest = nil
        
//        if spinner.isAnimating() {
//            spinner.stopAnimating()
//        }
    }
    
    override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes) {
        super.applyLayoutAttributes(layoutAttributes)
        
        // These are the two convenience height constants you've used previously.
        let standardHeight = FlickLayoutConstants.Cell.standardHeight
        let featuredHeight = FlickLayoutConstants.Cell.featuredHeight
        
        if let attributes = layoutAttributes as? CustomLayoutAttributes {
            // Calculate the delta of the cell as it's moving to figure out how much to adjust the alpha in the following step.
            //        let delta = ((featuredHeight - CGRectGetHeight(frame)) / (featuredHeight - standardHeight))
            let delta = (featuredHeight - attributes.height) / (featuredHeight - standardHeight)
            
            // Based on the range constants, update the cell's alpha based on the delta value.
            let minAlpha: CGFloat = 0.0
            let maxAlpha: CGFloat = 1.0
            
            blurView.alpha = (maxAlpha - (pow(delta, 3) * (maxAlpha - minAlpha)))
//            contentView.alpha = 1 - min((maxAlpha - (pow(delta, 3) * (maxAlpha - minAlpha))), 0.5)
        }
        
//        println("blurView.alpha \(blurView.alpha)")
//        println("transform3D: \(max(pow(delta, 2), 0.8))")
    }
    
    @IBAction func buyButtonTapped(sender: AnyObject) {
        
        if let buyURL = product?.buyURL {
            delegate?.openItemInStoreWithURL(NSURL(string: buyURL))
        }
    }
    
    @IBAction func infoButtonTapped(sender: AnyObject) {
        
        if let product = product {
            delegate?.displayMoreDetailsForProduct(product)
        }
    }
}
