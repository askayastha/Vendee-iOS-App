//
//  ColorView.swift
//  FlickShop
//
//  Created by Ashish Kayastha on 2/23/16.
//  Copyright © 2016 Ashish Kayastha. All rights reserved.
//

import UIKit

class ColorView: UIView {

    override var backgroundColor: UIColor? {
        didSet {
            if UIColor.clearColor().isEqual(backgroundColor) {
                backgroundColor = oldValue
            }
        }
    }
}
