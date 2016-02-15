//
//  ContainerFavoritesViewController.swift
//  FlickShop
//
//  Created by Ashish Kayastha on 2/11/16.
//  Copyright © 2016 Ashish Kayastha. All rights reserved.
//

import UIKit

class ContainerFavoritesViewController: UIViewController {
    
    var favoritesViewController: FavoritesViewController?
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
    
    func showNoFavoritesAlert() {
        let alert = UIAlertController(title: nil, message: "You haven't found a favorite yet!", preferredStyle: .Alert)
        let OKAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(OKAction)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "EmbedBrowseFavorites" {
            favoritesViewController = segue.destinationViewController as? FavoritesViewController
            print("HELLO I AM HERE")
            favoritesViewController?.dataModel = dataModel
            favoritesViewController?.search = Search(products: dataModel.favoriteProducts)
            favoritesViewController?.hideSpinner = {
                if self.spinner.isAnimating() {
                    self.spinner.stopAnimating()
                }
            }
        }
    }
}