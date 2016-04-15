//
//  FlickPageCell.swift
//  Flip
//
//  Created by Ashish Kayastha on 9/12/15.
//  Copyright (c) 2015 Razeware LLC. All rights reserved.
//

import UIKit
import SwiftyJSON
import SMPageControl

protocol FlickPageCellDelegate: class {
    func openItemInStoreWithProduct(product: Product)
    func openPhotosViewerForProduct(product: Product, andImageView imageView: UIImageView, onPage page: Int)
    func openActivityViewForProduct(product: Product, andImage image: UIImage?)
    func favoriteState(state: FavoriteState, forProduct product: Product)
}

enum FavoriteState {
    case Selected
    case Unselected
}

class FlickPageCell: UICollectionViewCell {
    
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var headerTitleLabel: UILabel!
    @IBOutlet weak var headerSubtitleLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: SMPageControl!
    @IBOutlet weak var scrollViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomImageViewLineSeparatorHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var topImageViewLineSeparatorHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    
    weak var delegate: FlickPageCellDelegate?
    var imageViews: [UIImageView?]
    var spinners: [UIActivityIndicatorView?]
    var favorited: Bool = false {
        didSet {
            favoriteButton.setImage(UIImage(named: "favorite"), forState: .Normal)
        }
    }
    var product: Product! {
        didSet {
            updateUI()
        }
    }
    var scrollViewBounds: CGRect {
        return fixFrame(scrollView.bounds)
    }
    var currentPage: Int {
        // First, determine which page is currently visible
        let pageWidth = scrollViewBounds.size.width
        let page = Int(floor((scrollView.contentOffset.x * 2.0 + pageWidth) / (pageWidth * 2.0)))
        
        return page
    }
    var blurView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .Light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        
        return blurView
    }()
    
    required init?(coder aDecoder: NSCoder) {
        imageViews = [UIImageView?]()
        spinners = [UIActivityIndicatorView?]()
        super.init(coder: aDecoder)

        layer.borderColor = UIColor(hexString: "#DFDFDF")?.CGColor
        layer.borderWidth = 0.5
        layer.cornerRadius = 5.0
        layer.masksToBounds = true
        
        blurView.frame = bounds
        contentView.addSubview(blurView)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        headerImageView.backgroundColor = UIColor(hexString: "#F2F2F2")
        headerImageView.layer.borderColor = UIColor(hexString: "#DFDFDF")?.CGColor
        headerImageView.layer.borderWidth = 0.5
        headerImageView.layer.cornerRadius = 5.0
        headerImageView.layer.masksToBounds = true
        
        pageControl.currentPageIndicatorImage = UIImage(named: "current_page_dot")
        pageControl.pageIndicatorImage = UIImage(named: "page_dot")
        pageControl.hidesForSinglePage = true
        
        buyButton.layer.cornerRadius = 18.0
        buyButton.adjustsImageWhenHighlighted = false
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        spinners.removeAll()
        imageViews.removeAll()
        scrollView.delegate = nil
        scrollView.subviews.forEach { $0.removeFromSuperview() }
        scrollView.setContentOffset(CGPointMake(0.0, 0.0), animated: false)
        headerImageView.image = nil
        headerTitleLabel.text = nil
        headerSubtitleLabel.text = nil
        favorited = false
    }
    
    override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes) {
        super.applyLayoutAttributes(layoutAttributes)
        
        // These are the two convenience height constants you've used previously.
        let standardHeight = FlickLayoutConstants.Cell.standardHeight
        let featuredHeight = FlickLayoutConstants.Cell.featuredHeight
        
        if let attributes = layoutAttributes as? CustomLayoutAttributes {
            // Calculate the delta of the cell as it's moving to figure out how much to adjust the alpha in the following step.
            //        let delta = ((featuredHeight - CGRectGetHeight(frame)) / (featuredHeight - standardHeight))
            let delta = (featuredHeight - attributes.height) / (featuredHeight - standardHeight)
            
            // Based on the range constants, update the cell's alpha based on the delta value.
            let minAlpha: CGFloat = 0.0
            let maxAlpha: CGFloat = 1.0
            
            blurView.alpha = (maxAlpha - (pow(delta, 3) * (maxAlpha - minAlpha)))
//            contentView.alpha = 1 - min((maxAlpha - (pow(delta, 3) * (maxAlpha - minAlpha))), 0.5)
        }
        
//        println("blurView.alpha \(blurView.alpha)")
//        println("transform3D: \(max(pow(delta, 2), 0.8))")
    }
    
    @IBAction func favoriteButtonTapped(sender: AnyObject) {
        toggleFavorited()
        
        if favorited {
            favoriteButton.imageView?.transform = CGAffineTransformMakeScale(0.7, 0.7)
            favoriteButton.setImage(UIImage(named: "favorite_selected"), forState: .Normal)
            
            UIView.animateKeyframesWithDuration(0.4, delay: 0, options: .CalculationModeCubic, animations: {
                UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.334, animations: {
                    self.favoriteButton.imageView?.transform = CGAffineTransformMakeScale(1.2, 1.2)
                })
                UIView.addKeyframeWithRelativeStartTime(0.334, relativeDuration: 0.333, animations: {
                    self.favoriteButton.imageView?.transform = CGAffineTransformMakeScale(0.9, 0.9)
                })
                UIView.addKeyframeWithRelativeStartTime(0.666, relativeDuration: 0.333, animations: {
                    self.favoriteButton.imageView?.transform = CGAffineTransformMakeScale(1.0, 1.0)
                })}, completion: nil
            )
            delegate?.favoriteState(.Selected, forProduct: product)
            
        } else {
            favoriteButton.setImage(UIImage(named: "favorite"), forState: .Normal)
            delegate?.favoriteState(.Unselected, forProduct: product)
        }
    }
    
    @IBAction func buyButtonTapped(sender: AnyObject) {
        delegate?.openItemInStoreWithProduct(product)
    }
    
    @IBAction func actionButtonTapped(sender: AnyObject) {
        delegate?.openActivityViewForProduct(product, andImage: imageViews[currentPage]?.image)
    }
    
    @IBAction func pageChanged(sender: UIPageControl) {
        UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseInOut, animations: {
            self.scrollView.contentOffset = CGPoint(
                x: self.scrollView.bounds.size.width * CGFloat(sender.currentPage),
                y: 0)
            },
            completion: nil)
    }
    
    // MARK: - Helper methods
    
    private func toggleFavorited() {
        favorited = !favorited
    }
    
    private func updateUI() {
        print("Product ID: \(product.id)")
        // Update header labels
        if let brand = product.brand {
            headerTitleLabel.text = JSON(brand)["name"].string
        } else if let retailer = product.retailer {
            headerTitleLabel.text = JSON(retailer)["name"].string
        }
        headerSubtitleLabel.text = product.unbrandedName
        
        // Update favorite button
        if favorited {
            favoriteButton.setImage(UIImage(named: "favorite_selected"), forState: .Normal)
        }
        
        // Update buy button
        var discountText = "0% Off"
        if let salePrice = product.salePrice {
            let discount = (product.price! - salePrice) * 100 / product.price!
            discountText = "\(Int(discount))% Off"
        }
        buyButton.setTitle(discountText, forState: .Normal)
        
        // Update page control
        pageControl.currentPage = currentPage
        pageControl.numberOfPages = product.largeImageURLs!.count
        
        // Reset spinners and image views
        for _ in 0..<product.largeImageURLs!.count {
            spinners.append(nil)
            imageViews.append(nil)
        }
        
        // Update scroll view
        scrollView.contentSize = CGSizeMake(
            scrollViewBounds.size.width * CGFloat(pageControl.numberOfPages),
            scrollViewBounds.size.height
        )
        
        // Load scroll pages
        loadVisiblePages()
        scrollView.delegate = self  // Delegate set here to prevent unwanted scrolling method calls.
    }
    
    private func loadPage(page: Int) {
        
        if page < 0 || page >= pageControl.numberOfPages {
            // If it's outside the range of what you have to display, then do nothing
            return
        }

        if let _ = imageViews[page] {
            // Do nothing. The view is already loaded.
        } else {
            var frame = scrollViewBounds   ; print("ScrollView Bounds: \(frame)")
            frame.origin.x = frame.size.width * CGFloat(page)
            frame.origin.y = 0
            
            // Spinner setup
            let spinner = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
            spinner.center = CGPoint(x: frame.origin.x + frame.size.width / 2, y: frame.size.height / 2)
            spinner.startAnimating()
            scrollView.addSubview(spinner)
            spinners[page] = spinner
            
            // ImageView setup
            let imageView = UIImageView()
            imageView.contentMode = .ScaleAspectFit
            imageView.userInteractionEnabled = true
            imageView.frame = frame
            imageView.pin_setImageFromURL(NSURL(string: product.largeImageURLs![page])!) { _ in
                spinner.stopAnimating()
            }
            
            // Setup gestures
            let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped(_:)))
            imageView.addGestureRecognizer(singleTapGesture)
            
            scrollView.addSubview(imageView)
            imageViews[page] = imageView
        }
    }
    
    private func purgePage(page: Int) {
        
        if page < 0 || page >= pageControl.numberOfPages {
            // If it's outside the range of what you have to display, then do nothing
            return
        }
        
        // Remove a spinner from the scroll view and reset the container array
        if let spinner = spinners[page] {
            spinner.removeFromSuperview()
            spinners[page] = nil
        }
        
        // Remove a page from the scroll view and reset the container array
        if let imageView = imageViews[page] {
            imageView.removeFromSuperview()
            imageViews[page] = nil
        }
    }
    
    private func loadVisiblePages() {
        
        // Update the page control
        pageControl.currentPage = currentPage
        print("Current Image: \(currentPage)")
        
        // Work out which pages you want to load
        let firstPage = currentPage - 1
        let lastPage = currentPage + 1
        
        // Guard against "fatal error: Can't form Range with end < start"
        if firstPage > 0 {
            // Purge anything before the first page
            for index in 0..<firstPage {
                purgePage(index)
            }
        }
        
        // Load pages in our range
        for index in firstPage...lastPage {
            loadPage(index)
        }
        
        // Guard against "fatal error: Can't form Range with end < start"
        if lastPage < pageControl.numberOfPages {
            // Purge anything after the last page
            for index in (lastPage + 1)..<pageControl.numberOfPages {
                purgePage(index)
            }
        }
    }
    
    func imageViewTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        delegate?.openPhotosViewerForProduct(product, andImageView: imageViews[currentPage]!, onPage: currentPage)
    }
}

extension FlickPageCell: UIScrollViewDelegate {
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        // Load the pages that are now on screen
        loadVisiblePages()
    }
}
