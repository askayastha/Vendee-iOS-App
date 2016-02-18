//
//  CategoryCell.swift
//  Vendee
//
//  Created by Ashish Kayastha on 10/23/15.
//  Copyright © 2015 Ashish Kayastha. All rights reserved.
//

import UIKit

class CategoryCell: UICollectionViewCell {
    
    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    
    var category: Category? {
        didSet {
            if let category = category {
                categoryImageView.image = category.picture
                categoryLabel.text = category.name
            }
        }
    }
    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//    }
//    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
//        layer.borderWidth = 1.0
//        layer.borderColor = UIColor(red: 238/255, green: 232/255, blue: 240/255, alpha: 1.0).CGColor
//        layer.cornerRadius = 5.0
//        layer.masksToBounds = true
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
//        layer.borderWidth = 3.0
//        layer.borderColor = UIColor(red: 238/255, green: 232/255, blue: 240/255, alpha: 1.0).CGColor
//        layer.cornerRadius = 5.0
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        categoryImageView.layer.cornerRadius = categoryImageView.bounds.size.width / 2
        categoryImageView.layer.masksToBounds = true
        
//        containerView.clipsToBounds = true
        containerView.backgroundColor = UIColor.clearColor()
        containerView.layer.shadowColor = UIColor.lightGrayColor().CGColor
//        containerView.layer.shadowColor = UIColor(red: 216/255, green: 216/255, blue: 216/255, alpha: 1.0).CGColor
        containerView.layer.shadowOffset = CGSizeMake(0, 0)
        containerView.layer.shadowOpacity = 1.0
        containerView.layer.shadowRadius = 3.0
        containerView.layer.shadowPath = UIBezierPath(
            roundedRect: categoryImageView.frame,
            cornerRadius: categoryImageView.bounds.size.width / 2
            ).CGPath
    }
}
