//
//  HomeViewController.swift
//  FlickShop
//
//  Created by Ashish Kayastha on 10/23/15.
//  Copyright © 2015 Ashish Kayastha. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var categories = Category.allCategories()
    var brands = Brand.allBrands()

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        view.layer.cornerRadius = 5.0
//        view.layer.masksToBounds = true
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        
//        backgroundImageView.image = categories[0].picture
        collectionView.decelerationRate = UIScrollViewDecelerationRateFast
        
//        collectionView.contentInset = UIEdgeInsets(
//            top: 0,
//            left: (collectionView.bounds.width - 200.0) / 2,
//            bottom: 0,
//            right: (collectionView.bounds.width - 200.0) / 2
//        )
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "BrowseCategory" {
//            let navigationController = segue.destinationViewController as! UINavigationController
//            let controller = navigationController.topViewController as! BrowseCollectionViewController
            let controller = segue.destinationViewController as! ContainerBrowseViewController

            let indexPath = sender as! NSIndexPath
            
            controller.productCategory = categories[indexPath.item].keyword
            controller.brands = brands
        }
    }

}

extension HomeViewController: UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CategoryCell", forIndexPath: indexPath) as! CategoryCell
//        let categoryImage = categories[indexPath.item].picture
//        cell.categoryImageView.image = blurView.blendViewWithImage(categoryImage, blendMode: .Multiply)
        cell.category = categories[indexPath.item]
        
        return cell
    }
}

extension HomeViewController: UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        appDelegate.productCategory = categories[indexPath.item].keyword
        
        performSegueWithIdentifier("BrowseCategory", sender: indexPath)
    }
    
//    func scrollViewDidScroll(scrollView: UIScrollView) {
//        print("ScrollViewDidScroll")
//    }
    
//    func scrollViewWillBeginDecelerating(scrollView: UIScrollView) {
//        print("scrollViewWillBeginDecelerating")
//    }
    
//    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
//        print("scrollViewWillBeginDragging")
//    }
//    
//    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
//        print("scrollViewDidEndDecelerating")
//    }
    
//    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
//        
//        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
//        let dragOffset = layout.itemSize.width + layout.minimumLineSpacing
//        
//        var offset = targetContentOffset.memory
//        let featuredItemIndex = max(0, Int(collectionView.contentOffset.x / dragOffset))
//        let itemIndex = round((offset.x + scrollView.contentInset.left) / dragOffset)
//        
//        print("\nCollectionView Offset: \(collectionView.contentOffset.x)")
//        print("Featured Index: \(featuredItemIndex)")
//        print("Index: \(itemIndex)")
//        print("Velocity: \(velocity)")
//        
//        var xOffset = itemIndex * dragOffset
////        var nextItemIndex = featuredItemIndex
//        
//        if velocity.x > 0.0 {
//            xOffset = CGFloat(featuredItemIndex + 1) * dragOffset
////            backgroundImageView.image = categories[featuredItemIndex + 1].picture
////            nextItemIndex = min(categories.count - 1, featuredItemIndex + 1)
//            
//        } else if velocity.x < -0.0 {
//            xOffset = CGFloat(featuredItemIndex) * dragOffset
////            backgroundImageView.image = categories[featuredItemIndex].picture
//        }
//        
////        UIView.transitionWithView(backgroundImageView, duration: 0.3, options: .TransitionCrossDissolve, animations: {
////            self.backgroundImageView.image = self.categories[nextItemIndex].picture
////            }, completion: nil)
//        
//        offset = CGPoint(x: xOffset, y: 0)
//        
//        targetContentOffset.memory = offset
//    }
    
//    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
//        
//        let layout = collectionViewLayout as! UICollectionViewFlowLayout
//        
//        let horizontalInset = (collectionView.bounds.width - layout.itemSize.width) / 2
//        return UIEdgeInsets(top: 0, left: horizontalInset, bottom: 0, right: horizontalInset)
//    }
}

extension HomeViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if navigationController?.viewControllers.count > 1 {
            return true
        }
        
        return false
    }
}