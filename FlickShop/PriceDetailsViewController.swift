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
    
    var product: Product!
    
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var salePriceLabel: UILabel!
    @IBOutlet weak var discountLabel: UILabel!
    
    var isPopUp = false
    
    enum AnimationStyle {
        case Slide
        case Fade
    }
    
    var dismissAnimationStyle = AnimationStyle.Fade
    
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
        Answers.logCustomEventWithName("Price Details View", customAttributes: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupView() {
        // View setup
        view.tintColor = UIColor(red: 20/255, green: 160/255, blue: 160/255, alpha: 1)
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
            let discount = (product.price! - salePrice) * 100 / product.price!
            discountText = "(\(Int(discount))% Off)"
        }
        discountLabel.text = discountText
        
        // Dismiss tap gesture setup
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "close:")
        tapRecognizer.cancelsTouchesInView = false
        tapRecognizer.delegate = self
        view.addGestureRecognizer(tapRecognizer)
        
        // Swipe gesture setup
        let swipeUpRecognizer = UISwipeGestureRecognizer(target: self, action: "close:")
        tapRecognizer.cancelsTouchesInView = false
        swipeUpRecognizer.delegate = self
        swipeUpRecognizer.direction = .Up
        
        let swipeDownRecognizer = UISwipeGestureRecognizer(target: self, action: "close:")
        tapRecognizer.cancelsTouchesInView = false
        swipeDownRecognizer.delegate = self
        swipeDownRecognizer.direction = .Down
        
        view.addGestureRecognizer(swipeUpRecognizer)
        view.addGestureRecognizer(swipeDownRecognizer)
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