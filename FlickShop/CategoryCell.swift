//
//  CategoryCell.swift
//  FlickShop
//
//  Created by Ashish Kayastha on 10/23/15.
//  Copyright © 2015 Ashish Kayastha. All rights reserved.
//

import UIKit

class CategoryCell: UICollectionViewCell {
    
    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var categoryLabel: UILabel!
    
    var category: Category? {
        didSet {
            if let category = category {
                categoryImageView.image = category.picture//.blendImageWithColor(UIColor.lightGrayColor(), blendMode: .Multiply)
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
        
        layer.borderWidth = 1.0
        layer.borderColor = UIColor(red: 238/255, green: 232/255, blue: 240/255, alpha: 1.0).CGColor
        layer.cornerRadius = 5.0
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
//        layer.borderWidth = 3.0
//        layer.borderColor = UIColor(red: 238/255, green: 232/255, blue: 240/255, alpha: 1.0).CGColor
//        layer.cornerRadius = 5.0
    }
}
