//
//  FlickPageCell.swift
//  Flip
//
//  Created by Ashish Kayastha on 9/12/15.
//  Copyright (c) 2015 Razeware LLC. All rights reserved.
//

import UIKit

protocol FlickPageCellDelegate: class {
    func openItemInStoreWithURL(url: NSURL?)
    func openPhotosViewerForProduct(product: Product, onPage page: Int)
    func openDetailsForProduct(product: Product)
    func openActivityViewForURL(url: String, andImage image: UIImage?)
}

class FlickPageCell: UICollectionViewCell {
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var brandNameLabel: UILabel!
    @IBOutlet weak var brandImageView: UIImageView!
    @IBOutlet weak var discountLabel: UILabel!
    @IBOutlet weak var scrollViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomImageViewLineSeparatorHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var topImageViewLineSeparatorHeightConstraint: NSLayoutConstraint!
//    @IBOutlet weak var topLikesCommentsViewLineSeparatorHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var buyButton: UIButton!
    
    weak var delegate: FlickPageCellDelegate?
    var imageViews: [UIImageView?]
    var spinners: [UIActivityIndicatorView?]
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
    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        
//        print("I AM HERE")
//    }
    
    required init?(coder aDecoder: NSCoder) {
        imageViews = [UIImageView?]()
        spinners = [UIActivityIndicatorView?]()
        super.init(coder: aDecoder)
        print("$$$$$$$$$$ FlickCell initialization $$$$$$$$$$")

        layer.borderWidth = 0.5
        layer.borderColor = UIColor(red: 223/255, green: 223/255, blue: 223/255, alpha: 1.0).CGColor
        
        blurView.frame = bounds
        contentView.addSubview(blurView)
    }
    
    override func awakeFromNib() {
        print("Yay. Awoke from Nib.")
        super.awakeFromNib()
        
        buyButton.layer.cornerRadius = 5.0
        buyButton.layer.masksToBounds = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        print("Yay. I am getting reused.")
        
        spinners.removeAll()
        imageViews.removeAll()
        scrollView.delegate = nil
        scrollView.subviews.forEach { $0.removeFromSuperview() }
        scrollView.setContentOffset(CGPointMake(0.0, 0.0), animated: false)
        brandImageView.image = nil
        discountLabel.text = nil
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
    
    @IBAction func buyButtonTapped(sender: AnyObject) {
        
        if let buyURL = product?.buyURL {
            delegate?.openItemInStoreWithURL(NSURL(string: buyURL))
        }
    }
    
    @IBAction func infoButtonTapped(sender: AnyObject) {
        
        if let product = product {
            delegate?.openDetailsForProduct(product)
        }
    }
    
    @IBAction func actionButtonTapped(sender: AnyObject) {
        
        if let product = product {
            let url = "https://www.vendeeapp.com/product?id=\(product.id!)"
            delegate?.openActivityViewForURL(url, andImage: imageViews[currentPage]?.image)
        }
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
    
    private func updateUI() {
        print("##### Updating UI #####")
        brandNameLabel.text = product!.brandedName
        
        if let salePrice = product.salePrice {
            let discount = (product.price! - salePrice) * 100 / product.price!
            discountLabel.text = "\(Int(discount))% Off"
        } else {
            discountLabel.text = "0% Off"
        }
        print("PRODUCT ID: \(product!.id)")
        // Setup page control
        pageControl.currentPage = currentPage
        pageControl.numberOfPages = product.largeImageURLs!.count
        
        for _ in 0..<product.largeImageURLs!.count {
            spinners.append(nil)
            imageViews.append(nil)
        }
        scrollView.contentSize = CGSizeMake(
            scrollViewBounds.size.width * CGFloat(pageControl.numberOfPages),
            scrollViewBounds.size.height
        )
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
            spinner.hidesWhenStopped = true
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
            
            // TapGestureRecognizer setup
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "imageViewTapped:")
            imageView.addGestureRecognizer(tapGestureRecognizer)
            
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
        
        
        // Purge anything before the first page
        for var index = 0; index < firstPage; ++index {
            purgePage(index)
        }
        
        // Load pages in our range
        for var index = firstPage; index <= lastPage; ++index {
            loadPage(index)
        }
        
        // Purge anything after the last page
        for var index = lastPage + 1; index < pageControl.numberOfPages; ++index {
            purgePage(index)
        }
    }
    
    func imageViewTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        delegate?.openPhotosViewerForProduct(product, onPage: currentPage)
    }
}

extension FlickPageCell: UIScrollViewDelegate {
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        // Load the pages that are now on screen
        print("scrollViewDidScroll")
        loadVisiblePages()
    }
}
