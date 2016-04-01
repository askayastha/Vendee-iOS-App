//
//  ContainerFavoritesViewController.swift
//  Vendee
//
//  Created by Ashish Kayastha on 2/11/16.
//  Copyright © 2016 Ashish Kayastha. All rights reserved.
//

import UIKit
import Crashlytics

class ContainerFavoritesViewController: UIViewController {
    
    @IBOutlet weak var messageLabel: UILabel!
    
    lazy private var spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        spinner.color = UIColor(white: 0.1, alpha: 0.5)
        spinner.startAnimating()
        
        return spinner
    }()
    
    deinit {
        print("Deallocating ContainerFavoritesViewController!")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        automaticallyAdjustsScrollViewInsets = false
        
        // Spinner setup
        view.addSubview(spinner)
        
        spinner.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activateConstraints([
            spinner.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor),
            spinner.centerYAnchor.constraintEqualToAnchor(view.centerYAnchor)
            ])
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        print("FavoriteProducts Count: \(FavoritesModel.sharedInstance().favoriteProducts.count)")
        if FavoritesModel.sharedInstance().favoriteProducts.count == 0 {
            spinner.stopAnimating()
            messageLabel.hidden = false
        } else {
            messageLabel.hidden = true
        }
        
        GoogleAnalytics.trackScreenForName("Favorites View")
        Answers.logCustomEventWithName("Favorites View", customAttributes: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "EmbedBrowseFavorites" {
            let favoriteProductsCopy = FavoritesModel.sharedInstance().favoriteProducts.mutableCopy() as! NSMutableOrderedSet
            
            let favoritesViewController = segue.destinationViewController as? FavoritesViewController
            favoritesViewController?.search = Search(products: favoriteProductsCopy)
            favoritesViewController?.scout = PhotoScout(products: favoriteProductsCopy, totalItems: favoriteProductsCopy.count)
            favoritesViewController?.animateSpinner = { [weak self] animate in
                guard let strongSelf = self else { return }
                if animate {
                    strongSelf.spinner.startAnimating()
                    UIView.animateWithDuration(0.3, animations: {
                        strongSelf.spinner.transform = CGAffineTransformIdentity
                        strongSelf.spinner.alpha = 1.0
                        }, completion: nil)
                    
                } else {
                    UIView.animateWithDuration(0.3, animations: {
                        strongSelf.spinner.transform = CGAffineTransformMakeScale(0.1, 0.1)
                        strongSelf.spinner.alpha = 0.0
                        }, completion: { _ in
                            strongSelf.spinner.stopAnimating()
                    })
                }
            }
        }
    }
}
