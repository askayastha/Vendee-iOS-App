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
