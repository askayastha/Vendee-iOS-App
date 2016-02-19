//
//  ContainerFavoritesViewController.swift
//  Vendee
//
//  Created by Ashish Kayastha on 2/11/16.
//  Copyright © 2016 Ashish Kayastha. All rights reserved.
//

import UIKit

class ContainerFavoritesViewController: UIViewController {
    
    var dataModel: DataModel!
    
    @IBOutlet weak var messageLabel: UILabel!
    
    lazy private var spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        spinner.color = UIColor(white: 0.1, alpha: 0.5)
        spinner.startAnimating()
        
        return spinner
    }()
    
    deinit {
        print("Deallocating ContainerFavoritesViewController !!!!!!!!!!!!!!!")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        // Spinner setup
        spinner.center = CGPoint(x: view.center.x, y: view.center.y)
        view.addSubview(spinner)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print("ContainerFavoritesViewControllerWillAppear")
        print("FavoriteProducts Count: \(dataModel.favoriteProducts.count)")
        if dataModel.favoriteProducts.count == 0 {
            spinner.stopAnimating()
            messageLabel.hidden = false
        } else {
            messageLabel.hidden = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "EmbedBrowseFavorites" {
            let favoriteProductsCopy = dataModel.favoriteProducts.mutableCopy() as! NSMutableOrderedSet
            
            let favoritesViewController = segue.destinationViewController as? FavoritesViewController
            favoritesViewController?.dataModel = dataModel
            favoritesViewController?.search = Search(products: favoriteProductsCopy)
            favoritesViewController?.scout = PhotoScout(products: favoriteProductsCopy)
            favoritesViewController?.hideSpinner = { [unowned self] in
                if self.spinner.isAnimating() {
                    self.spinner.stopAnimating()
                }
            }
        }
    }
}
