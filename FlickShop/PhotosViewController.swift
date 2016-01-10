//
//  PhotosViewController.swift
//  FlickShop
//
//  Created by Ashish Kayastha on 1/7/16.
//  Copyright © 2016 Ashish Kayastha. All rights reserved.
//

import UIKit

class PhotosViewController: UIViewController {
    
    @IBOutlet weak var pagingScrollView: UIScrollView!
    @IBOutlet weak var photoScrubbingScrollView: UIScrollView!
    
    let scout = ImageScout()
    var imageViews: [UIImageView?]
    var tinyImageViews: [UIImageView]
    var zoomScrollViews: [UIScrollView]
    var spinners: [UIActivityIndicatorView?]
    
    var product: Product!
    var page: Int!
    var selectedPage: Int = 0 {
        didSet {
            tinyImageViews[oldValue].layer.borderColor = UIColor.clearColor().CGColor
            tinyImageViews[oldValue].layer.borderWidth = 0.0
            tinyImageViews[selectedPage].layer.borderColor = UIColor.orangeColor().CGColor
            tinyImageViews[selectedPage].layer.borderWidth = 1.0
        }
    }
    var currentPage: Int {
        get {
            // First, determine which page is currently visible
            let pageWidth = pagingScrollViewBounds.size.width
            let page = Int(floor((pagingScrollView.contentOffset.x * 2.0 + pageWidth) / (pageWidth * 2.0)))
            
            return page
        }
        set(newCurrentPage) {
            pagingScrollView.setContentOffset(CGPointMake(pagingScrollViewBounds.size.width * CGFloat(newCurrentPage), 0), animated: true)
        }
    }
    var pagingScrollViewBounds: CGRect {
        return fixFrame(pagingScrollView.bounds)
    }
    
    required init?(coder aDecoder: NSCoder) {
        imageViews = [UIImageView?]()
        tinyImageViews = [UIImageView]()
        zoomScrollViews = [UIScrollView]()
        spinners = [UIActivityIndicatorView?]()
        super.init(coder: aDecoder)
        print("##### PhotosViewController initialization #####")
    }
    
    @IBAction func closeButton() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        for page in 0..<product.largeImageURLs!.count {
            
            let scrubberFrame = CGRect(
                origin: CGPoint(x: 60 * CGFloat(page), y: 0),
                size: CGSize(width: 60, height: photoScrubbingScrollView.bounds.size.height)
            )
            
            // Nil initialization
            imageViews.append(nil)
            spinners.append(nil)
            product.largeImageSizes.append(nil)
            
            // Tiny ImageView setup
            let tinyImageView = UIImageView()
            tinyImageView.tag = page
            tinyImageView.contentMode = .ScaleToFill
            tinyImageView.userInteractionEnabled = true
            tinyImageView.frame = scrubberFrame
            tinyImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "photoScrubberTapped:"))
            tinyImageView.pin_setImageFromURL(NSURL(string: product.tinyImageURLs![page])!)
            photoScrubbingScrollView.addSubview(tinyImageView)
            
//            // Spinner setup
//            let spinner = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
//            var frame = pagingScrollViewBounds   ; print("ScrollView Bounds: \(frame)")
//            frame.origin.x = frame.size.width * CGFloat(page)
//            frame.origin.y = 0
//            spinner.hidesWhenStopped = true
//            spinner.center = CGPoint(x: frame.origin.x + frame.size.width / 2, y: frame.size.height / 2)
//            spinner.startAnimating()
//            pagingScrollView.addSubview(spinner)
//            spinners[page] = spinner
            
            // Zoom ScrollView setup
            var zoomFrame = pagingScrollViewBounds
            zoomFrame.origin.x = zoomFrame.size.width * CGFloat(page)
            zoomFrame.origin.y = 0
            
            // Double TapGestureRecognizer setup
            let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: "scrollViewDoubleTapped:")
            doubleTapRecognizer.numberOfTapsRequired = 2
            doubleTapRecognizer.numberOfTouchesRequired = 1
            
            let zoomScrollView = UIScrollView(frame: zoomFrame)
            zoomScrollView.addGestureRecognizer(doubleTapRecognizer)
            zoomScrollView.delegate = self

            pagingScrollView.addSubview(zoomScrollView)
            tinyImageViews.append(tinyImageView)
            zoomScrollViews.append(zoomScrollView)
        }
        print("Paging Scroll View width: \(pagingScrollViewBounds.size.width)")
        pagingScrollView.contentSize = CGSizeMake(
            pagingScrollViewBounds.size.width * CGFloat(product.largeImageURLs!.count),
            pagingScrollViewBounds.size.height
        )
        loadVisiblePages()
        pagingScrollView.delegate = self
        currentPage = page
        selectedPage = page
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Helper methods
    private func loadPage(page: Int) {
        
        if page < 0 || page >= imageViews.count {
            // If it's outside the range of what you have to display, then do nothing
            return
        }
        
        if let _ = imageViews[page] {
            // Do nothing. The view is already loaded.
            // Zoom ScrollView scale setup
//            let zoomScrollView = zoomScrollViews[page]
//            let scaleWidth = zoomScrollView.bounds.size.width / zoomScrollView.contentSize.width
//            let scaleHeight = zoomScrollView.bounds.size.height / zoomScrollView.contentSize.height
//            let minScale = min(scaleWidth, scaleHeight)
//            zoomScrollViews[page].zoomScale = minScale
//            centerScrollViewContentsForPage(page)
            
        } else {
            var frame = pagingScrollViewBounds   ; print("ScrollView Bounds: \(frame)")
            frame.origin.x = frame.size.width * CGFloat(page)
            frame.origin.y = 0
            
            // Spinner setup
            let spinner = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
            spinner.hidesWhenStopped = true
            spinner.center = CGPoint(x: frame.origin.x + frame.size.width / 2, y: frame.size.height / 2)
            spinner.startAnimating()
            pagingScrollView.addSubview(spinner)
            spinners[page] = spinner
            largeImageSetupForPage(page)
        }
    }
    
    private func largeImageSetupForPage(page: Int) {
        print("LargeImageSetupForPage: \(page)")
        
        // Large ImageView setup
        let largeImageView = UIImageView()
        largeImageView.contentMode = .ScaleAspectFit
//        largeImageView.frame = CGRect(origin: CGPointMake(0, 0), size: product.largeImageSizes[page]!)
        largeImageView.pin_setImageFromURL(NSURL(string: product.largeImageURLs![page])!) { _ in
            self.spinners[page]?.stopAnimating()
            
            print("Large Image Size: \(largeImageView.image!.size)")
            largeImageView.frame = CGRect(origin: CGPointMake(0, 0), size: largeImageView.image!.size)
            
            // Zoom ScrollView scale setup
            let zoomScrollView = self.zoomScrollViews[page]
            zoomScrollView.addSubview(largeImageView)
            zoomScrollView.contentSize = largeImageView.image!.size
            
            let scaleWidth = zoomScrollView.bounds.size.width / zoomScrollView.contentSize.width
            let scaleHeight = zoomScrollView.bounds.size.height / zoomScrollView.contentSize.height
            let minScale = min(scaleWidth, scaleHeight)
            zoomScrollView.minimumZoomScale = minScale
            zoomScrollView.maximumZoomScale = 1.0
            zoomScrollView.zoomScale = minScale
            
            self.centerScrollViewContentsForPage(page)
        }
        
//        zoomScrollViews[page].addSubview(largeImageView)
//        zoomScrollViews[page].contentSize = product.largeImageSizes[page]!
        imageViews[page] = largeImageView
        
//        // Zoom ScrollView scale setup
//        let scrollViewFrame = zoomScrollViews[page].frame
//        let scaleWidth = scrollViewFrame.size.width / zoomScrollViews[page].contentSize.width
//        let scaleHeight = scrollViewFrame.size.height / zoomScrollViews[page].contentSize.height
//        let minScale = min(scaleWidth, scaleHeight);
//        zoomScrollViews[page].minimumZoomScale = minScale;
//        zoomScrollViews[page].maximumZoomScale = 1.0
//        zoomScrollViews[page].zoomScale = minScale;
//        
//        centerScrollViewContentsForPage(page)
    }
    
    private func purgePage(page: Int) {
        
        if page < 0 || page >= imageViews.count {
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
        
        // Update the photo scubbing scrollview
        selectedPage = currentPage
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
        for var index = lastPage + 1; index < imageViews.count; ++index {
            purgePage(index)
        }
    }
    
    func populateLargePhotoSizeForPage(page: Int, completion: (Bool) -> ()) {
        print("i am being called way too much")
        var success = false
        
        scout.scoutImageWithURI(product.largeImageURLs![page]) { error, size, type in
            
            if let unwrappedError = error {
                print(unwrappedError.code)
                self.populateLargePhotoSizeForPage(page, completion: completion)
                
            } else {
                let imageSize = CGSize(width: size.width, height: size.height)
                print("Image Size: \(imageSize)")
                self.product.largeImageSizes[page] = imageSize
                success = true
                
                dispatch_async(dispatch_get_main_queue()) {
                    completion(success)
                }
            }
        }
    }
    
    func scrollViewDoubleTapped(recognizer: UITapGestureRecognizer) {
        // 1
        let pointInView = recognizer.locationInView(imageViews[currentPage]!)
        
        // 2
        var newZoomScale = zoomScrollViews[currentPage].zoomScale * 1.5
        newZoomScale = min(newZoomScale, zoomScrollViews[currentPage].maximumZoomScale)
        
        // 3
        let scrollViewSize = zoomScrollViews[currentPage].bounds.size
        let w = scrollViewSize.width / newZoomScale
        let h = scrollViewSize.height / newZoomScale
        let x = pointInView.x - (w / 2.0)
        let y = pointInView.y - (h / 2.0)
        
        let rectToZoomTo = CGRectMake(x, y, w, h);
        
        // 4
        zoomScrollViews[currentPage].zoomToRect(rectToZoomTo, animated: true)
    }
    
    func photoScrubberTapped(recognizer: UITapGestureRecognizer) {
        let page = recognizer.view!.tag
        
//        let zoomScrollView = zoomScrollViews[page]
//        let scaleWidth = zoomScrollView.bounds.size.width / zoomScrollView.contentSize.width
//        let scaleHeight = zoomScrollView.bounds.size.height / zoomScrollView.contentSize.height
//        let minScale = min(scaleWidth, scaleHeight)
//        zoomScrollViews[page].zoomScale = minScale
//        centerScrollViewContentsForPage(page)
        
        pagingScrollView.setContentOffset(CGPoint(x: pagingScrollViewBounds.size.width * CGFloat(page), y: 0), animated: true)
    }
}

// MARK: - ScrollView delegate

extension PhotosViewController: UIScrollViewDelegate {
    
    private func centerScrollViewContentsForPage(page: Int) {
        if let imageView = imageViews[page] {
            let boundsSize = pagingScrollViewBounds.size
            var contentsFrame = imageView.frame
            
            if contentsFrame.size.width < boundsSize.width {
                contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0
            } else {
                contentsFrame.origin.x = 0.0
            }
            
            if contentsFrame.size.height < boundsSize.height {
                contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0
            } else {
                contentsFrame.origin.y = 0.0
            }
            
            imageView.frame = contentsFrame
        }
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageViews[currentPage]
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        centerScrollViewContentsForPage(currentPage)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        // Load the pages that are now on screen
        print("scrollViewDidScroll")
        loadVisiblePages()
    }
}
