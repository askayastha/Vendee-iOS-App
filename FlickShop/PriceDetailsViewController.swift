//
//  PriceDetailsViewController.swift
//  Vendee
//
//  Created by Ashish Kayastha on 1/27/16.
//  Copyright © 2016 Ashish Kayastha. All rights reserved.
//

import UIKit
import Crashlytics

class PriceDetailsViewController: UIViewController {
    
    enum AnimationStyle {
        case Slide
        case Fade
    }
    
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var salePriceLabel: UILabel!
    @IBOutlet weak var discountLabel: UILabel!
    
    private(set) var isPopUp = false
    private(set) var dismissAnimationStyle = AnimationStyle.Fade
    
    var product: Product!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        modalPresentationStyle = .Custom
        transitioningDelegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
        // Log screen views
        GoogleAnalytics.trackScreenForName("Price Details View")
        Answers.logCustomEventWithName("Price Details View", customAttributes: getAttributesForProduct(product))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupView() {
        // View setup
        view.backgroundColor = UIColor.clearColor()
        
        // Popup setup
        popupView.layer.cornerRadius = 10
        
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
        
        var discountText = "(0% Off)"
        
        if let salePrice = product.salePrice {
            let discount = (product.price - salePrice) * 100 / product.price
            discountText = "(\(Int(discount))% Off)"
        }
        discountLabel.text = discountText
        
        // Dismiss tap gesture setup
        let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(close(_:)))
        singleTapGesture.cancelsTouchesInView = false
        singleTapGesture.delegate = self
        view.addGestureRecognizer(singleTapGesture)
        
        // Swipe gesture setup
        let swipeUpGesture = UISwipeGestureRecognizer(target: self, action: #selector(close(_:)))
        swipeUpGesture.cancelsTouchesInView = false
        swipeUpGesture.delegate = self
        swipeUpGesture.direction = .Up
        
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(close(_:)))
        swipeDownGesture.cancelsTouchesInView = false
        swipeDownGesture.delegate = self
        swipeDownGesture.direction = .Down
        
        view.addGestureRecognizer(swipeUpGesture)
        view.addGestureRecognizer(swipeDownGesture)
    }

}

extension PriceDetailsViewController: UIViewControllerTransitioningDelegate {
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
        return DimmingPresentationController(presentedViewController: presented, presentingViewController: presenting)
    }
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SlideInAnimationController()
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch dismissAnimationStyle {
        case .Slide:
            return SlideOutAnimationController()
        case .Fade:
            return FadeOutAnimationController()
        }
    }
}

extension PriceDetailsViewController: UIGestureRecognizerDelegate {
    func close(tapGestureRecognizer: UIGestureRecognizer) {
        dismissAnimationStyle = .Slide
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        return (touch.view === self.view)
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}